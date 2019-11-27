function handler () {
    RESPONSE=$(aws --version 2>&1)
    echo "{\"version\":\"${RESPONSE}\"}"
}
