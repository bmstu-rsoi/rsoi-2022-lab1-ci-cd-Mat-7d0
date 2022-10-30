(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

using Lab01
const UserApp = Lab01
Lab01.main()
