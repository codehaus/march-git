################################################################################
#  Copyright (c) 2004-2007, by OpenXource, LLC. All rights reserved.           #
#
#  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF OPENXOURCE                   #
#
#  The copyright notice above does not evidence any                            #
#  actual or intended publication of such source code.                         #
################################################################################

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "codehaus03.managed.contegix.com"
role :app, "codehaus03.managed.contegix.com"
role :db,  "codehaus03.managed.contegix.com", :primary => true

