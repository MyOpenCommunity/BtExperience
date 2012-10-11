# We use an empirical test to recognize the platform.
defineTest(isArm) {
    # In this case we are searching for the substring 'arm' in the QMAKE_CXX
    # predefined variable, which usually contains the compiler name
    TEST_QMAKE_CXX = $$find(QMAKE_CXX,arm)
    !isEmpty(TEST_QMAKE_CXX) {
        return(true)
    }
    # With Open Embedded builds, QMAKE_CXX is only a reference to the OE_QMAKE_CXX
    # environment variable, so we cannot use the above test, but we have to extract
    # the value from OE_QMAKE_CXX and test it.
    OECXX = $$(OE_QMAKE_CXX)
    TEST_OE_QMAKE_CXX = $$find(OECXX,arm)
    !isEmpty(TEST_OE_QMAKE_CXX) {
        return(true)
    }
    return (false)
}
