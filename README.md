# swifty-code-coverage

A github action for generating code coverage report for your ios/macos/spm project.

## Example

Here is an actual workflow (https://github.com/michaelhenry/create-report/actions/runs/2156329862) that uses this action and it produced a codecov report on this PR (https://github.com/michaelhenry/create-report/pull/14).

### Codecov

```yml
jobs:
  code-coverage-report:
    runs-on: ubuntu-latest
    steps:
      - name: Test
        uses: actions/checkout@v1
      - run: swift test --enable-code-coverage
      - uses: ./.github/actions/lcov
        with:
          build-path: .build
          target: GithubChecksPackageTests.xctest
          is-spm: true
      - name: Upload to Codecov
        run: |
          bash <(curl https://codecov.io/bash) -f "coverage/*.info"
        shell: bash
        env:
          CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

### Code Climate

```yml
jobs:
  code-coverage-report:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v1
      - run: xcodebuild test -project App.xcodeproj -scheme App -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone X,OS=13.0' -enableCodeCoverage YES
      - uses: michaelhenry/swifty-code-coverage@v1.0.0
        with:
          build-path: DerivedData
          target: App.app
          is-spm: false
      - name: Upload to Code Climate
        run: |
          curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-darwin-amd64 > ./cc-test-reporter
          chmod +x ./cc-test-reporter
          ./cc-test-reporter before-build
          ./cc-test-reporter after-build --coverage-input-type lcov
        shell: bash
        env:
          CC_TEST_REPORTER_ID: ${{ secrets.CC_TEST_REPORTER_ID }}
```

> For some reason even though the code-coverage was generate from the same llvm version, codeclimate is returning an error " ./cc-test-reporter: cannot execute binary file: Exec format error" when using an ubuntu machine.
