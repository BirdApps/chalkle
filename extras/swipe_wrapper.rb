class SwipeWrapper
  include HTTParty
  format :json
  CURRENCIES = ['USD', 'NZD', 'CNY', 'HKD', 'GBP', 'AUD', 'JPY', 'CAD', 'SGD', 'ZAR', 'EUR', 'KRW']

  def create_tx_identifier_for(params)
    swype_reconnection_attempts ||= 3
    @amount = params[:amount]
    @quantity = params[:quantity]
    @currency = 'NZD'
    @booking_set_id = params[:booking_set_id]
    @description = params[:description]
    @return_url = params[:return_url]
    response = self.class.post(swipe_url, query: query_params)
  rescue SocketError => e
    retry if (swype_reconnection_attempts -= 1) > 0
  else
    parse_identifier_from_response(response)
  end

  def verify(transaction_id)
    swype_reconnection_attempts ||= 3
    verify = HTTParty.get("https://api.swipehq.com/verifyTransaction.php?api_key=#{ENV["SWIPE_API_KEY"]}&merchant_id=#{ENV["SWIPE_MERCHANT_ID"]}&transaction_id=#{transaction_id}")
  rescue SocketError => e
    retry if (swype_reconnection_attempts -= 1) > 0
  else
    JSON.parse verify
  end

  def currency=(c)
    @currency = c.upcase
  end

  def currency
    if CURRENCIES.include? @currency
     @currency
    else
      CURRENCIES.first
    end
  end

  class << self
    def verify(tx_id)
      wrapper = SwipeWrapper.new
      verify = wrapper.verify tx_id
    end
  end

  private


  def parse_identifier_from_response(response)
    response["data"]["identifier"]
  end

  def swipe_url
    ENV["SWIPE_PAYMENT_URL"]
  end

  def query_params
    {
      api_key: ENV["SWIPE_API_KEY"],
      merchant_id: ENV["SWIPE_MERCHANT_ID"],
      td_callback_url: @return_url,
      td_item: @description,
      td_currency: currency,
      td_description: @description,
      td_amount: @amount,
      td_user_data: @booking_set_id,
      td_default_quantity: @quantity
    }
  end
end
