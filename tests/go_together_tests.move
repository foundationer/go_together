
#[test_only]
module go_together::go_together_tests;

use go_together::app;

const ENotImplemented: u64 = 0;

#[test]
fun test_go_together() {
    // pass
}

#[test, expected_failure(abort_code = ::go_together::go_together_tests::ENotImplemented)]
fun test_go_together_fail() {
    abort ENotImplemented
}

