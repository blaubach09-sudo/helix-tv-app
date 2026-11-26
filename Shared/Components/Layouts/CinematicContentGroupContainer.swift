//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct CinematicContentGroupContainer<Content: View>: View {

    @Environment(\.frameForParentView)
    private var frameForParentView

    private let content: Content
    private let heightFraction: CGFloat

    /// - Parameter heightFraction: Helix TV — share of the scroll view's height the header
    ///   reserves (1 = full screen). Item pages use less so the first row of content peeks.
    init(heightFraction: CGFloat = 1, @ContentBuilder content: () -> Content) {
        self.heightFraction = heightFraction
        self.content = content()
    }

    private var resolvedHeight: CGFloat {
        let parentHeight = frameForParentView[.scrollView, default: .zero].frame.height

        return max(parentHeight - 75, 0) * heightFraction
    }

    @ContentBuilder
    var body: some View {
        content
            .frame(minHeight: resolvedHeight, alignment: .bottomLeading)
            .frame(maxWidth: .infinity)
    }
}
