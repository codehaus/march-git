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

-- If your PARTS don't have a length set, you can copy the length from the CONTENTS table.
-- This will likely only occur if you have a buggy script.
UPDATE PARTS P
SET LENGTH = (SELECT LENGTH FROM CONTENTS C WHERE P.CONTENT_ID = C.ID)
WHERE P.CONTENT_ID IS NOT NULL
  AND (P.LENGTH = 0 OR P.LENGTH IS NULL);