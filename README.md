# swifty-code-coverage

A github action for generating code coverage report for your ios/macos/spm project.

[![codecov](https://codecov.io/gh/michaelhenry/swifty-code-coverage/branch/main/graph/badge.svg?token=I7B7SJCM34)](https://codecov.io/gh/michaelhenry/swifty-code-coverage)

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
      - uses: michaelhenry/swifty-code-coverage@v1.0.0
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
      - run: xcodebuild test -project App.xcodeproj -scheme App -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone X,OS=13.0' -enableCodeCoverage YES -derivedDataPath DerivedData
      - uses: michaelhenry/swifty-code-coverage@v1.0.0
        with:
          build-path: DerivedData
          target: App.app
          is-spm: false
      - name: Publish to code climate
        uses: paambaati/codeclimate-action@v3.0.0
        env:
          CC_TEST_REPORTER_ID: ${{ secrets.CC_TEST_REPORTER_ID }}
        with:
          coverageLocations: |
            coverage/lcov.info:lcov
```

> For some reason even though the code-coverage was generate from the same llvm version, codeclimate is returning an error " ./cc-test-reporter: cannot execute binary file: Exec format error" when using an ubuntu machine.

## Note

If your project is an SPM project, please use the `.xctest` file as `target` which was generated from `swift test --enable-code-coverage` and set the `is-spm` to `true`.

Eg.

```yml
  - run: swift test --enable-code-coverage
  - uses: michaelhenry/swifty-code-coverage@v1.0.0
    with:
      build-path: .build
      target: AppTests.xctest
      is-spm: true
```

Otherwise, if your project is an ios/macos that uses the `xcodebuild test` to test, please use the `.app` as `target` which was the file generated from the `xcodebuild test -enableCodeCoverage YES`  and set the `is-spm` to `false`.

Eg.

```yml
  - run: xcodebuild test -project App.xcodeproj -scheme App -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone X,OS=13.0' -enableCodeCoverage YES -derivedDataPath DerivedData
  - uses: michaelhenry/swifty-code-coverage@v1.0.0
    with:
      build-path: DerivedData
      target: App.app
      is-spm: false
```

## FAQ

### How to ignore view controller files?

Just add the regex for `*ViewController.swift` as `ignore-filename-regex` param.

For example:

```yml
- uses: michaelhenry/swifty-code-coverage@v1.0.0
  with:
    build-path: DerivedData
    target: Demo.app
    is-spm: false
    ignore-filename-regex: '^[\w,\s-]+ViewController\.swift$'
```
### Don't want to use other third party code coverage service for the report or analysis?

You can still view the code coverage report from the logs(stdout) of llvm-cov report.

Eg.

<img width="1302" alt="Screen Shot 2022-11-02 at 01 51 54" src="https://user-images.githubusercontent.com/717992/199263153-22d35899-66d9-404a-b682-0b453de314a8.png">

