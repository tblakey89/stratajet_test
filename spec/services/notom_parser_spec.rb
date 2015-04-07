require 'spec_helper'

describe NotomParser do
  describe "generate_output" do
    context "invalid NOTOMs" do
      describe "single notom does not have match requirements" do
        let(:notom) { "B0510/15 NOTAMN
                      Q) ESAA/QSTAH/IV/BO /A /000/999/6232N01727E005
                      A) ESNN B) 1503020000 C) 1503082359
                      E) AERODROME CONTROL TOWER (TWR) HOURS OF OPS/SERVICE
                      MON 0500-2215 TUE 0500-2130 WED-THU 0500-2300 FRI 0500-2015 SAT
                      1100-1300 SUN 1115-2300
                      CREATED: 27 Feb 2015 10:38:00
                      SOURCE: EUECYIYN" }

        it "should return an empty array" do
          data = NotomParser.new notom
          data.generate_output.length.should eql 0
        end
      end
    end

    context "valid NOTOM" do
      describe "single NOTOM matches requirements" do
        let(:notom) { "Q) ESAA/QFAAH/IV/NBO/A /000/999/5746N01404E005
                      A) ESGJ B) 1502271138 C) 1503012359
                      E) AERODROME HOURS OF OPS/SERVICE MON-WED 0500-1830 THU 0500-2130
                      FRI
                      0730-2100 SAT 0630-0730, 1900-2100 SUN CLOSED
                      CREATED: 27 Feb 2015 11:40:00
                      SOURCE: EUECYIYN" }

        it "should return 1 parsed NOTOM" do
          data = NotomParser.new notom
          data.generate_output.length.should eql 1
        end

        it "should show the right icao code" do
          data = NotomParser.new notom
          data.generate_output[0][:icao].should eql "ESGJ"
        end

        it "should show the right time for Tuesday" do
          data = NotomParser.new notom
          p data.generate_output[0][:opening_times][1]
          data.generate_output[0][:opening_times][1].should eql "0500-1830"
        end

        it "should show two times for Saturday" do
          data = NotomParser.new notom
          data.generate_output[0][:opening_times][5].should eql "0630-0730\n1900-2100"
        end

        it "should show closed for Sunday" do
          data = NotomParser.new notom
          data.generate_output[0][:opening_times][6].should eql "CLOSED"
        end
      end
    end

    context "more than one notom" do
      describe "should only return two results" do
        let(:notom) { "B0519/15 NOTAMN
                      Q) ESAA/QFAAH/IV/NBO/A /000/999/5746N01404E005
                      A) ESGJ B) 1502271138 C) 1503012359
                      E) AERODROME HOURS OF OPS/SERVICE MON-WED 0500-1830 THU 0500-2130
                      FRI
                      0730-2100 SAT 0630-0730, 1900-2100 SUN CLOSED
                      CREATED: 27 Feb 2015 11:40:00
                      SOURCE: EUECYIYN
                      \r\n\r\n
                      B0517/15 NOTAMN
                      Q) ESAA/QSTAH/IV/BO /A /000/999/5746N01404E005
                      A) ESGJ B) 1502271133 C) 1503012359
                      E) AERODROME CONTROL TOWER (TWR) HOURS OF OPS/SERVICE MON-THU
                      0000-0100, 0500-2359 FRI 0000-0100, 0730-2100 SAT 0630-0730,
                        1900-2100 SUN 2200-2359
                      CREATED: 27 Feb 2015 11:35:00
                      SOURCE: EUECYIYN
                      \r\n\r\n
                      B0508/15 NOTAMN
                      Q) ESAA/QFAAH/IV/NBO/A /000/999/5746N01404E005
                      A) ESGJ B) 1503020000 C) 1503222359
                      E) AERODROME HOURS OF OPS/SERVICE MON 0500-2000 TUE-THU 0500-2100
                      FRI
                      0545-2100 SAT0630-0730 1900-2100 SUN 1215-2000
                      CREATED: 26 Feb 2015 10:54:00
                      SOURCE: EUECYIYN" }

        it "should return two results" do
          data = NotomParser.new notom
          p data.generate_output
          data.generate_output.length.should eql 2
        end
      end
    end
  end
end
