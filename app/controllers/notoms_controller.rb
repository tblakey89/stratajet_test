class NotomsController < ApplicationController

  def input

  end

  def output
    notom_data = NotomParser.new params[:notom_data]
    @output_data = notom_data.generate_output
  end

end
