require 'spec_helper'

describe "/api/v1/games", :type => :controller do

  describe "creating a new game" do

    context "when authorized" do
      it "should create a new game" do
        #c = Game.count
        #json = { name: 'Test', players: [ 'Mike', 'Greg' ] }
        #post :create, json
        #Game.count.should == c + 1
        #response.status.should eq(200)
        ##JSON.parse(response.body)["message"] =~ /authorized/
      end
    end
  end
end