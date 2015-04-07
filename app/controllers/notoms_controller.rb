class NotomsController < ApplicationController

  def input

  end

  def output
    parsed_data = NotomParser.new params[:notom_data]
  end

end
