//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

enum AppIcon: String, CaseIterable, Displayable, Identifiable {

    /// Helix TV ships one icon: the Helix mark on carbon.
    case helix

    var iconName: String {
        "AppIcon-helix"
    }

    var id: String {
        iconName
    }

    var alternateIconName: String? {
        nil
    }

    var displayTitle: String {
        "Helix TV"
    }

    static func resolve(alternateIconName: String?) -> Self {
        .helix
    }
}
