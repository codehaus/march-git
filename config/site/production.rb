################################################################################
#  Copyright 2007-2008 Codehaus Foundation
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

# This file contains the site specific production configuration (as opposed to the environment specific production configuration)

raise Exception.new("This is a sample, it should never be called during development (or production)")

March::MAIL_ROOT  = "/var/www/domains/hausfoundation.org/archive/mail"
March::MAIL_QUEUE = "/tmp/mail-queue"

March::SUBSCRIBER_HOST='archive.hausfoundation.org'

March::POP_USERNAME='march-inbox@archive.hausfoundation.org'
March::POP_PASSWORD='legba'
March::POP_HOST='localhost'
March::POP_PORT=110

March::PROFILE = false

March::DEBUG_LOG=false

March::GOOGLE_AD_CLIENT="pub-3023399591478482" #the codehaus ad provider id; feel free not to change it :)
March::GOOGLE_AD_SLOT_TOP = nil
March::GOOGLE_AD_SLOT_BOTTOM = nil