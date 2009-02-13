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
#
#  Only modifications to this file are licenced under ASL2.  Original code     #
#  is licenced under the same licence as Ruby                                  #
################################################################################

# $Id: rfc2047.rb,v 1.2 2003/04/14 00:17:18 sam Exp $
#
# An implementation of RFC 2047 decoding.
#
# This module depends on the iconv library by Nobuyoshi Nakada, which I've 
# heard may be distributed as a standard part of Ruby 1.8.
#
# Copyright (c) Sam Roberts <sroberts / uniserve.com> 2003
#
# This file is distributed under the same terms as Ruby.
require 'iconv'

module March::Rfc2047

  WORD = %r{=\?([!#$\\%&'*+-/0-9A-Z\\^\`a-z{|}~]+)\?([BbQq])\?([!->@-~]+)\?=} # :nodoc:

  # Decodes a string, +from+, containing RFC 2047 encoded words into a target
  # character set, +target+. See iconv_open(3) for information on the
  # supported target encodings. If one of the encoded words cannot be
  # converted to the target encoding, it is left in its encoded form.
  def self.decode_to(target, from)
    out = from.gsub(WORD) do
      |word|
      charset, encoding, text = $1, $2, $3
      
      # B64 or QP decode, as necessary:
      case encoding
        when 'b', 'B'
          #puts text
          text = text.unpack('m*')[0]
          #puts text.dump

        when 'q', 'Q'
          # RFC 2047 has a variant of quoted printable where a ' ' character
          # can be represented as an '_', rather than =32, so convert
          # any of these that we find before doing the QP decoding.
          text = text.tr("_", " ")
          text = text.unpack('M*')[0]

        # Don't need an else, because no other values can be matched in a
        # WORD.
      end

      # Convert:
      #
      # Remember - Iconv.open(to, from)!
      begin
        text = Iconv.iconv(target, charset, text).join
        #puts text.dump
      rescue Errno::EINVAL, Iconv::IllegalSequence
        # Replace with the entire matched encoded word, a NOOP.
        text = word
      end
    end
  end
end