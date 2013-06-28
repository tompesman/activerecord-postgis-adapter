# -----------------------------------------------------------------------------
#
# PostGIS adapter for ActiveRecord
#
# -----------------------------------------------------------------------------
# Copyright 2010-2012 Daniel Azuma
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


module ActiveRecord  # :nodoc:

  module ConnectionHandling  # :nodoc:


    if defined?(::RUBY_ENGINE) && ::RUBY_ENGINE == 'jruby'

      require 'active_record/connection_adapters/jdbcpostgresql_adapter'
      require 'active_record/connection_adapters/postgis_adapter/shared/jdbc_compat'


      def postgresql_connection(config_)
        ::ActiveRecord::ConnectionAdapters::PostGISAdapter.create_jdbc_connection(self, config_)
      end

      alias_method :jdbcpostgresql_connection, :postgresql_connection


    else


      require 'pg'


      # Based on the default <tt>postgresql_connection</tt> definition from
      # ActiveRecord.

      def postgresql_connection(config_)
        # FULL REPLACEMENT because we need to create a different class.
        conn_params_ = config_.symbolize_keys

        conn_params_.delete_if { |_, v_| v_.nil? }

        # Map ActiveRecords param names to PGs.
        conn_params_[:user] = conn_params_.delete(:username) if conn_params_[:username]
        conn_params_[:dbname] = conn_params_.delete(:database) if conn_params_[:database]

        # Forward only valid config params to PGconn.connect.
        conn_params_.keep_if { |k_, _| VALID_CONN_PARAMS.include?(k_) }

        # The postgres drivers don't allow the creation of an unconnected PGconn object,
        # so just pass a nil connection object for the time being.
        ::ActiveRecord::ConnectionAdapters::PostGISAdapter::MainAdapter.new(nil, logger, conn_params_, config_)
      end


    end


  end

end
