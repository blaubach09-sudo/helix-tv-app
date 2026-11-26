//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

import CollectionHStack
import SwiftUI

struct PosterHStack<
    Data: Collection
>: View where Data.Element: Poster, Data.Index == Int {

    @AdaptiveLayout
    private var viewLayout

    let elements: Data
    let displayType: PosterDisplayType
    let size: PosterDisplayType.Size
    let action: (Data.Element, Namespace.ID) -> Void
    var onReachedTrailingEdge: (() -> Void)? // Helix TV: load the next page as the user reaches the end of a row

    private var layout: CollectionHStackLayout {
        #if os(tvOS)
        .grid(
            columns: displayType == .landscape ? 6 : 9, // Helix TV: denser rows (HIG 9-col grid)
            rows: 1,
            columnTrailingInset: 0
        )
        #else
        .minimumWidth(
            columnWidth: viewLayout.posterMinimumWidth(for: displayType, size: size),
            rows: 1,
            columnFraction: 0.5
        )
        #endif
    }

    @ContentBuilder
    var body: some View {
        CollectionHStack(
            uniqueElements: elements,
            layout: layout
        ) { item in
            PosterButton(
                item: item,
                displayType: displayType,
                size: size
            ) { namespace in
                action(item, namespace)
            }
        }
        .clipsToBounds(false)
        .insets(horizontal: viewLayout.edgePadding)
        .itemSpacing(viewLayout.itemSpacing)
        .scrollBehavior(.continuousLeadingEdge)
        .onReachedTrailingEdge(offset: .columns(3)) { onReachedTrailingEdge?() }
        .contentInsetAdjustmentBehavior(.never)
        .withViewContext(.isThumb)
    }
}
