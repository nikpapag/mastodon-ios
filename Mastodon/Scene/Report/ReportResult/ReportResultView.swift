//
//  ReportResultView.swift
//  Mastodon
//
//  Created by MainasuK on 2022-5-11.
//

import UIKit
import SwiftUI
import MastodonLocalization
import MastodonSDK
import MastodonUI
import MastodonAsset
import CoreDataStack

struct ReportResultView: View {
    
    @ObservedObject var viewModel: ReportResultViewModel
    
    var avatarView: some View {
        HStack {
            Spacer()
            ZStack {
                AnimatedImage(imageURL: viewModel.avatarURL)
                    .frame(width: 106, height: 106, alignment: .center)
                    .background(Color(UIColor.systemFill))
                    .cornerRadius(27)
                Text(L10n.Scene.Report.reported)
                    .font(Font(FontFamily.Staatliches.regular.font(size: 49) as CTFont))
                    .foregroundColor(Color(Asset.Scene.Report.reportBanner.color))
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: -2, trailing: 10))
                    .background(Color(viewModel.backgroundColor))
                    .cornerRadius(7)
                    .padding(7)
                    .background(Color(Asset.Scene.Report.reportBanner.color))
                    .cornerRadius(12)
                    .rotationEffect(.degrees(-8))
                    .offset(x: 0, y: -5)
            }
            Spacer()
        }
        .padding()
    }
    
    // TODO: i18n
    var body: some View {
        ScrollView(.vertical) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.headline)
                        .foregroundColor(Color(Asset.Colors.Label.primary.color))
                        .font(Font(UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .systemFont(ofSize: 28, weight: .bold)) as CTFont))
                    avatarView
                    Text(verbatim: "While we review this, you can take action against @\(viewModel.username)")
                        .foregroundColor(Color(Asset.Colors.Label.secondary.color))
                        .font(Font(UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .systemFont(ofSize: 17, weight: .regular)) as CTFont))
                }
                Spacer()
            }
            .padding()
            
            VStack(spacing: 32) {
                // Follow
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unfollow @\(viewModel.username)")
                        .font(.headline)
                        .foregroundColor(Color(Asset.Colors.Label.primary.color))
                    ReportActionButton(
                        action: {
                            viewModel.followActionPublisher.send()
                        },
                        title: viewModel.relationshipViewModel.isFollowing ? "Unfollow" : "Unfollowed",
                        isBusy: viewModel.isRequestFollow
                    )
                }
                
                // Mute
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mute @\(viewModel.username)")
                        .font(.headline)
                        .foregroundColor(Color(Asset.Colors.Label.primary.color))
                    Text(verbatim: "You won’t see their posts or reblogs in your home feed. They won’t know they’ve been muted.")
                        .foregroundColor(Color(Asset.Colors.Label.secondary.color))
                        .font(Font(UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 13, weight: .regular)) as CTFont))
                    ReportActionButton(
                        action: {
                            viewModel.muteActionPublisher.send()
                        },
                        title: viewModel.relationshipViewModel.isMuting ? L10n.Common.Controls.Friendship.muted : L10n.Common.Controls.Friendship.mute,
                        isBusy: viewModel.isRequestMute
                    )
                }
                
                // Block
                VStack(alignment: .leading, spacing: 4) {
                    Text("Block @\(viewModel.username)")
                        .font(.headline)
                        .foregroundColor(Color(Asset.Colors.Label.primary.color))
                    Text(verbatim: "They will no longer be able to follow or see your posts, but they can see if they’ve been blocked.")
                        .foregroundColor(Color(Asset.Colors.Label.secondary.color))
                        .font(Font(UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 13, weight: .regular)) as CTFont))
                    ReportActionButton(
                        action: {
                            viewModel.blockActionPublisher.send()
                        },
                        title: viewModel.relationshipViewModel.isBlocking ? L10n.Common.Controls.Friendship.blocked : L10n.Common.Controls.Friendship.block,
                        isBusy: viewModel.isRequestBlock
                    )
                }
            }
            .padding()
            
            Spacer()
                .frame(minHeight: viewModel.bottomPaddingHeight)
        }
        .background(
            Color(viewModel.backgroundColor)
        )
    }

}

struct ReportActionButton: View {

    var action: () -> Void
    var title: String
    var isBusy: Bool

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                ProgressView()
                    .opacity(isBusy ? 1 : 0)
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(Asset.Colors.Label.primary.color))
                    .opacity(isBusy ? 0 : 1)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }

}

#if DEBUG
struct ReportResultView_Previews: PreviewProvider {
    
    static var viewModel: ReportResultViewModel {
        let context = AppContext.shared
        let request = MastodonUser.sortedFetchRequest
        request.fetchLimit = 1
        
        let property = MastodonUser.Property(
            identifier: "1",
            domain: "domain.com",
            id: "1",
            acct: "@user@domain.com",
            username: "user",
            displayName: "User",
            avatar: "",
            avatarStatic: "",
            header: "",
            headerStatic: "",
            note: "",
            url: "",
            statusesCount: Int64(100),
            followingCount: Int64(100),
            followersCount: Int64(100),
            locked: false,
            bot: false,
            suspended: false,
            createdAt: Date(),
            updatedAt: Date(),
            emojis: [],
            fields: []
        )
        let user = try! context.managedObjectContext.fetch(request).first ?? MastodonUser.insert(into: context.managedObjectContext, property: property)
        
        return ReportResultViewModel(
            context: context,
            user: .init(objectID: user.objectID)
        )
    }
    static var previews: some View {
        Group {
            NavigationView {
                ReportResultView(viewModel: viewModel)
                    .navigationBarTitle(Text(""))
                    .navigationBarTitleDisplayMode(.inline)
            }
            NavigationView {
                ReportResultView(viewModel: viewModel)
                    .navigationBarTitle(Text(""))
                    .navigationBarTitleDisplayMode(.inline)
            }
            .preferredColorScheme(.dark)
        }
    }
}
#endif
