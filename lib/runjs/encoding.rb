module RunJS

  module Encoding

    if ''.respond_to?(:encode)

      def encode(text, to, from = nil)
        text.encode(to, from)
      end

    else

      require 'iconv'

      def encode(text, to, from = nil)
        return text unless from
        Iconv.conv(to, from, text)
      end

    end

  end

end
