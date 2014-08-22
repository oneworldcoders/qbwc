module QBWC
  class QbwcJob < ActiveRecord::Base

    def generate_request
      obj = self.klass.constantize.send(:find, self.klass_id)
      payload = obj.qb_payload
      request = QBWC::Request.new(payload)
      return request
    end

    def handle_response(session)
      obj = klass.constantize.send(:find, klass_id)
      resp = if session.response
               # all is well(?). mark the previous job as processed
               self.processed = true
               self.save!
               Hash.from_xml(session.response.gsub("\n", ""))
             elsif session.error
               {error: session.error}
             end
      obj.qb_response_handler(resp)
    end
  end
end