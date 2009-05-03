################################################################################
#  Copyright 2006-2009 Codehaus Foundation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
################################################################################

March::MAIL_ROOT  = RAILS_ROOT + "/tmp/mail"
March::MAIL_QUEUE = RAILS_ROOT + "/tmp/mail-queue"


March::SUBSCRIBER_HOST='archive.localhost'

March::POP_USERNAME='march-inbox@localhost'
March::POP_PASSWORD='password'
March::POP_HOST='localhost'
March::POP_PORT=110

March::DEBUG_LOG=true

March::PROFILE=true
# The API key controls who can update a given March server; access control is "somewhat" coarse.
March::TOKEN = 'X'

#DEPRECATED - just don't fill in March::GOOGLE_ADS if you don't want adverts
#Should we show advertising?
March::ADS = true

March::GOOGLE_ANALYTICS = 'UA-5294457-1'

March::GOOGLE_ADS[:top] = {
  :client => 'pub-5267633279208525',
  :slot   => '7297104046',
  :width  => 728,
  :height => 15
}

March::GOOGLE_ADS[:top_banner] = {
  :client => 'pub-5267633279208525',
  :slot   => '2116975762',
  :width  => 468,
  :height => 60
}

March::GOOGLE_ADS[:content] = {
  :client => 'pub-5267633279208525',
  :slot   => '8710293701',
  :width  => 160,
  :height => 600
}

March::GOOGLE_ADS[:content_horiz] = {
  :client => 'pub-5267633279208525',
  :slot   => '1331589381',
  :width  => 250,
  :height => 250
}


March::GOOGLE_ADS[:bottom] = {
  :client => 'pub-5267633279208525',
  :slot   => '2116975762', #:slot   => '2029848481',
  :width  => 468,
  :height => 60
}



#MailHide Public Key
MH_PUB     = '01FPm-gxHKOTy7a4pLdtBvrQ=='
#MailHide Private Key
MH_PRIV    = '29C91F299EF63F7722BE3515A1160837'
#ReCaptcha Public Key (localhost key)
RCC_PUB    = '6LeJ0QIAAAAAAA_QdYGrk7TvDeKOkMTR3xkesaBb'
#ReCaptcha Private Key (localhost key)
RCC_PRIV   = '6LeJ0QIAAAAAAKjC0mkogSaJjpNcnDezTPzdeI6E'