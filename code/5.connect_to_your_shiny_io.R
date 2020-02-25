#install.packages("rsconnect")
library(rsconnect)
library(here)

# don't forget token to install
# rsconnect::setAccountInfo(name='', token ='', secret = '')

# to check sth
rsconnect.http.trace == T

rsconnect::deployApp(here::here())
