//Copyright Hauke Schade, 2012-2013
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

//import QtQuick 1.1 // harmattan
import QtQuick 2.0 // sailfish

ListModel {
    id: root

    property int selectedIndex: -1

    function update() {
        var ttrss = rootWindow.getTTRSS();
        ttrss.updateCategories(function() {
            root.load()
        })
    }

    function load() {
        var ttrss = rootWindow.getTTRSS()
        var showAll = ttrss.getShowAll()
        rootWindow.showAll = showAll
        var categories = ttrss.getCategories()
        root.clear()
        if(categories && categories.length) {
            var totalUnreadCount = 0

            //first add all the categories with unread itens
            for(var category = 0; category < categories.length; category++) {
                if (categories[category].id >= 0)
                    totalUnreadCount += parseInt(categories[category].unread);

                var title = ttrss.html_entity_decode(categories[category].title,'ENT_QUOTES')
                if (categories[category].id == ttrss.constants['categories']['ALL'])
                    title = constant.allFeeds
                if (categories[category].id == ttrss.constants['categories']['LABELS'])
                    title = constant.labelsCategory
                if (categories[category].id == ttrss.constants['categories']['SPECIAL'])
                    title = constant.specialCategory
                if (categories[category].id == ttrss.constants['categories']['UNCATEGORIZED'])
                    title = constant.uncategorizedCategory

                root.append({
                                title:       title,
                                unreadcount: parseInt(categories[category].unread),
                                categoryId:  parseInt(categories[category].id)
                            });
            }

            if(totalUnreadCount > 0 || showAll) {
                //Add the "All" category
                root.insert(0, {
                                title: constant.allFeeds,
                                categoryId: parseInt(ttrss.constants['categories']['ALL']),
                                unreadcount: totalUnreadCount,
                            });
            }
        }
    }

    function getTotalUnreadItems() {
        if (root.count <= 0)
            return 0
        else {
            var m = root.get(0)
            return m.unreadcount
        }
    }

    function getSelectedItem() {
        if (root.selectedIndex === -1)
            return null;

        return root.get(root.selectedIndex)
    }

    function updateSelectedUnreadCount(op) {
        var m = root.getSelectedItem()
        root.setProperty(root.selectedIndex, "unreadcount", op(m.unreadcount))
    }

    function updateUnreadCountForId(id, op) {
        for(var category = 0; category < root.count; category++) {
            var m = root.get(category)
            if (m.categoryId == id) {
                root.setProperty(category, "unreadcount", op(m.unreadcount))
                break
            }
        }
    }
}