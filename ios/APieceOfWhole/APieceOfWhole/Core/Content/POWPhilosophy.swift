import Foundation

struct POWLayerSummary: Identifiable, Sendable {
    let id: String
    let title: String
    let systemImage: String
    let shortDescription: String
    let detail: String
}

struct POWBelief: Identifiable, Sendable {
    let id: String
    let title: String
    let body: String
}

enum POWPhilosophy {
    static let appName = "Here"

    static let batesonQuote = "The human individual is in some degree a fiction."
    static let batesonAttribution = "Gregory Bateson"
    static let batesonQuoteSource = "Inaugural Eric Berne Lecture in Social Psychotherapy, March 1977."

    static let signatureLine = "We are each a piece of something whole."

    static let thesis = "The health of the self, our relationships, and our communities are the same work at different scales."

    static let welcomeCopy = "Begin with the body. Practice peace together. Step outward with care."

    static let onboardingCopy = "This starts with you, not because you are the problem, but because you are the beginning."

    static let applicationCopy = "You do not have to have it all figured out. This is a place to practice being honest, connected, grounded, and ready to act at a sustainable pace."

    static let practiceCopy = "Practice is how the philosophy becomes embodied: regulated enough to be honest, connected enough to grow, grounded enough to act."

    static let learnCopy = "Learn the ideas behind Self, Together, and Community, then test them against your own lived experience."

    static let myPieceCopy = "Agency is knowing your piece: your gifts, values, capacity, boundaries, and next contribution."

    static let civicCopy = "Civic life here is nonpartisan, values-based participation rooted in care rather than ideology."

    static let spiralCopy = "Self, Together, and Community are not a checklist to complete. They are places to return to and deepen over time."

    static let attribution = "Working philosophy by Nicole Stone, April 2026."

    static let selfCopy = "Self is the foundation: knowing yourself, regulating your nervous system, and learning how to return without shame."

    static let togetherCopy = "Together is the soul. Peace is better than pleasure because peace can stay with you. Co-regulation is a practical way to bring steadiness into the relationships you care about."

    static let communityCopy = "Community is the invitation outward: walking prompts, neighbor connection, gratitude for the land, and small local intentions that can accumulate."

    static let whyHereCopy = "Your application is not just intake. It is a record of why you began, what you hoped might change, and what kind of participation felt honest."

    static let workingLines = [
        "Complacency is the rot of tomorrow.",
        "Killing in the name of is still killing.",
        signatureLine
    ]

    static let layers: [POWLayerSummary] = [
        POWLayerSummary(
            id: "self_regulation",
            title: "Self-Regulation",
            systemImage: "brain.head.profile",
            shortDescription: "Body, breath, nervous system, and inner life.",
            detail: "The foundation. You cannot pour from an empty cup, but filling the cup is not the end of the story."
        ),
        POWLayerSummary(
            id: "co_regulation",
            title: "Co-Regulation",
            systemImage: "person.2",
            shortDescription: "Shared regulation, attunement, and relational practice.",
            detail: "The missing piece in many wellness frameworks: personal healing becomes relational."
        ),
        POWLayerSummary(
            id: "community",
            title: "Community",
            systemImage: "person.3",
            shortDescription: "Slow, purposeful connection around shared values.",
            detail: "Not a social feed. Circles, depth, trust, and belonging over performance or breadth."
        ),
        POWLayerSummary(
            id: "agency",
            title: "Agency",
            systemImage: "hand.raised",
            shortDescription: "Knowing your piece and your sustainable contribution.",
            detail: "The bridge between inner work and outer action. Choice and freedom restored."
        ),
        POWLayerSummary(
            id: "civic_engagement",
            title: "Civic Engagement",
            systemImage: "building.columns",
            shortDescription: "Local participation grounded in care.",
            detail: "Governance literacy, community participation, and relational advocacy without partisan sorting."
        )
    ]

    static let beliefs: [POWBelief] = [
        POWBelief(
            id: "connection",
            title: "Connection is the foundation",
            body: "The health of any system, from a person to a democracy, depends on the quality of its relationships."
        ),
        POWBelief(
            id: "process",
            title: "How we do things matters",
            body: "Process is not separate from outcome. You cannot use disconnection to build connection."
        ),
        POWBelief(
            id: "pace",
            title: "Change should be deep, not destabilizing",
            body: "Nervous systems, communities, and democracies all have a window of tolerance. Root work and slow work are not the same as no work."
        ),
        POWBelief(
            id: "care",
            title: "Care is not weakness",
            body: "Care is a sophisticated and durable intelligence, even when systems make it invisible."
        ),
        POWBelief(
            id: "plurality",
            title: "No single framework owns the truth",
            body: "The app should hold space for plurality, lived experience, humility, and the unknown."
        ),
        POWBelief(
            id: "living_world",
            title: "We are part of the living world",
            body: "What we practice inward, we practice outward toward each other and the earth we share."
        )
    ]
}
