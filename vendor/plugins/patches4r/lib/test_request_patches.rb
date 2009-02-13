
module ActionController
    class TestRequest  < AbstractRequest
      def referer=(ref)
        @env['HTTP_REFERER'] = ref
      end

      def referer
        @env['HTTP_REFERER']
      end
    end
end

