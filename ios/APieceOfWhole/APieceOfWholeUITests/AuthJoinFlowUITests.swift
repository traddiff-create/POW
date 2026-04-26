import XCTest

@MainActor
final class AuthJoinFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
    }

    func testCreateAccountOnboardSubmitApplicationSignOutAndSignIn() {
        launchSimulation()

        tap("welcome.applyToJoinButton")
        type("create.emailField", "qa+join@example.test")
        type("create.passwordField", "CorrectHorseBattery1!")
        type("create.confirmPasswordField", "CorrectHorseBattery1!")
        tap("create.submitButton")

        setSwitch("onboarding.ageToggle", on: true)
        tap("onboarding.ageContinueButton")
        setSwitch("onboarding.termsToggle", on: true)
        setSwitch("onboarding.privacyToggle", on: true)
        setSwitch("onboarding.communityToggle", on: true)
        tap("onboarding.agreementsContinueButton")
        type("onboarding.displayNameField", "QA Joiner")
        tap("onboarding.finishButton")

        tap("cohort.applyButton.22222222-2222-4222-8222-222222222222")
        type("application.motivationField", "I want to practice steadier participation.")
        type("application.hopedChangeField", "I want to become more grounded and useful.")
        type("application.howHeardField", "QA simulation")
        setSwitch("application.agreementsToggle", on: true)
        setSwitch("application.safetyToggle", on: true)
        tap("application.submitButton")

        XCTAssertTrue(element("applicationStatus.headline").waitForExistence(timeout: 5))
        XCTAssertEqual(element("applicationStatus.headline").label, "Application Received")

        tap("applicant.accountMenu")
        tapMenuButton("Sign Out")

        tap("welcome.signInButton")
        type("signIn.emailField", "qa+join@example.test")
        type("signIn.passwordField", "CorrectHorseBattery1!")
        tap("signIn.submitButton")

        XCTAssertTrue(element("cohort.applicationStatus.22222222-2222-4222-8222-222222222222").waitForExistence(timeout: 5))
    }

    func testPasswordMismatchBlocksAccountCreation() {
        launchSimulation()

        tap("welcome.applyToJoinButton")
        type("create.emailField", "qa+join@example.test")
        type("create.passwordField", "CorrectHorseBattery1!")
        type("create.confirmPasswordField", "WrongPassword1!")
        tap("create.submitButton")

        XCTAssertTrue(element("create.errorText").waitForExistence(timeout: 3))
        XCTAssertEqual(element("create.errorText").label, "Passwords do not match.")
    }

    func testRequiredControlsRemainDisabledUntilValid() {
        launchSimulation()

        tap("welcome.applyToJoinButton")
        type("create.emailField", "qa+join@example.test")
        type("create.passwordField", "CorrectHorseBattery1!")
        type("create.confirmPasswordField", "CorrectHorseBattery1!")
        tap("create.submitButton")

        let ageContinueButton = app.buttons["onboarding.ageContinueButton"]
        XCTAssertTrue(ageContinueButton.waitForExistence(timeout: 5))
        XCTAssertFalse(ageContinueButton.isEnabled)
        setSwitch("onboarding.ageToggle", on: true)
        let enabled = NSPredicate(format: "isEnabled == true")
        expectation(for: enabled, evaluatedWith: ageContinueButton)
        waitForExpectations(timeout: 2)
    }

    func testSimulatedOnboardingFailureDoesNotAdvance() {
        launchSimulation(extraArguments: ["--simulate-onboarding-failure"])

        tap("welcome.applyToJoinButton")
        type("create.emailField", "qa+join@example.test")
        type("create.passwordField", "CorrectHorseBattery1!")
        type("create.confirmPasswordField", "CorrectHorseBattery1!")
        tap("create.submitButton")

        setSwitch("onboarding.ageToggle", on: true)
        tap("onboarding.ageContinueButton")

        XCTAssertTrue(element("onboarding.ageErrorText").waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Before we begin"].exists)
        XCTAssertFalse(element("onboarding.agreementsContinueButton").exists)
    }

    func testGuestSeesHereThreeLegTabs() {
        launchSimulation()

        tap("welcome.guestButton")

        XCTAssertTrue(app.tabBars.buttons["Self"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Together"].exists)
        XCTAssertTrue(app.tabBars.buttons["Community"].exists)
    }

    private func launchSimulation(extraArguments: [String] = []) {
        app = XCUIApplication()
        app.launchArguments = ["--simulate-auth-flow"] + extraArguments
        app.launch()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func tap(_ identifier: String, timeout: TimeInterval = 6) {
        let target = element(identifier)
        XCTAssertTrue(target.waitForExistence(timeout: timeout), "Missing element \(identifier)")
        makeHittable(target)
        target.tap()
    }

    private func type(_ identifier: String, _ text: String, timeout: TimeInterval = 6) {
        let target = element(identifier)
        XCTAssertTrue(target.waitForExistence(timeout: timeout), "Missing element \(identifier)")
        makeHittable(target)
        target.tap()
        target.typeText(text)
    }

    private func tapMenuButton(_ title: String) {
        let button = app.buttons[title]
        XCTAssertTrue(button.waitForExistence(timeout: 3), "Missing menu button \(title)")
        button.tap()
    }

    private func setSwitch(_ identifier: String, on desiredState: Bool, timeout: TimeInterval = 6) {
        let target = app.switches[identifier]
        XCTAssertTrue(target.waitForExistence(timeout: timeout), "Missing switch \(identifier)")
        makeHittable(target)
        for _ in 0..<3 where switchIsOn(target) != desiredState {
            target.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        }
        XCTAssertEqual(switchIsOn(target), desiredState, "Switch \(identifier) did not reach expected state")
    }

    private func switchIsOn(_ element: XCUIElement) -> Bool {
        if let value = element.value as? String {
            return value == "1" || value.lowercased() == "on"
        }
        if let value = element.value as? Bool {
            return value
        }
        return false
    }

    private func makeHittable(_ element: XCUIElement) {
        guard !element.isHittable else { return }
        for _ in 0..<6 where !element.isHittable {
            app.swipeUp()
        }
    }
}
