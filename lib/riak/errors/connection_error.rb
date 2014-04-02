require 'riak/errors/base'

module Riak
  class ConnectionError < Error
  end

  class TlsError < ConnectionError
    class CertHostMismatchError < TlsError
      def initialize
        super t('ssl.cert_host_mismatch')
      end
    end

    class CertNotValidError < TlsError
      def initialize
        super t('ssl.cert_not_valid')
      end
    end

    class CertRevokedError < TlsError
      def initialize
        super t('ssl.cert_revoked')
      end
    end
  end
end
