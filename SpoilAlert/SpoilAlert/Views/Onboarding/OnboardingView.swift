import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    private let pages = [
        OnboardingPage(
            icon: "bottle.fill",
            title: "Track Your Skincare",
            subtitle: "Never use expired products again. SpoilAlert keeps track of every product's shelf life."
        ),
        OnboardingPage(
            icon: "camera",
            title: "Scan PAO Symbols",
            subtitle: "Point your camera at the Period After Opening icon and we'll calculate the expiry date automatically."
        ),
        OnboardingPage(
            icon: "bell.badge.fill",
            title: "Get Timely Reminders",
            subtitle: "Receive alerts at 7, 3, and 1 day before expiry so you can use products in time."
        ),
        OnboardingPage(
            icon: "book.fill",
            title: "Journal Your Skin",
            subtitle: "Track your skin condition daily and discover which products work best for you."
        )
    ]

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<pages.count, id: \.self) { index in
                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: pages[index].icon)
                        .font(.system(size: 72))
                        .foregroundColor(.accentColor)

                    Text(pages[index].title)
                        .font(.title.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text(pages[index].subtitle)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer()

                    if index == pages.count - 1 {
                        Button {
                            hasCompletedOnboarding = true
                        } label: {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding(.horizontal, 32)
                    }

                    Spacer()
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
}
