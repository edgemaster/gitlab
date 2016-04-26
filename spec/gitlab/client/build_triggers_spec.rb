require 'spec_helper'
require 'uri'

describe Gitlab::Client do
  describe ".triggers" do
    before do
      stub_get("/projects/3/triggers", "triggers")
      @triggers = Gitlab.triggers(3)
    end

    it "should get the correct resource" do
      expect(a_get("/projects/3/triggers")).to have_been_made
    end

    it "should return an array of project's triggers" do
      expect(@triggers).to be_a Gitlab::PaginatedResponse
      expect(@triggers.first.token).to eq("fbdb730c2fbdb095a0862dbd8ab88b")
    end
  end

  describe ".trigger_detail" do
    before do
      stub_get("/projects/3/triggers/7b9148c158980bbd9bcea92c17522d", "trigger")
      @trigger = Gitlab.trigger_detail(3, "7b9148c158980bbd9bcea92c17522d")
    end

    it "should get the correct resource" do
      expect(a_get("/projects/3/triggers/7b9148c158980bbd9bcea92c17522d")).to have_been_made
    end

    it "should return information about a trigger" do
      expect(@trigger.created_at).to eq("2015-12-23T16:25:56.760Z")
      expect(@trigger.token).to eq("7b9148c158980bbd9bcea92c17522d")
    end
  end

  describe ".create_trigger" do
    before do
      stub_post("/projects/3/triggers", "trigger")
      @trigger = Gitlab.create_trigger(3)
    end

    it "should get the correct resource" do
      expect(a_post("/projects/3/triggers")).to have_been_made
    end

    it "should return information about a new trigger" do
      expect(@trigger.created_at).to eq("2015-12-23T16:25:56.760Z")
      expect(@trigger.token).to eq("7b9148c158980bbd9bcea92c17522d")
    end
  end

  describe ".remove_trigger" do
    before do
      stub_delete("/projects/3/triggers/7b9148c158980bbd9bcea92c17522d", "trigger")
      @trigger = Gitlab.remove_trigger(3, "7b9148c158980bbd9bcea92c17522d")
    end

    it "should get the correct resource" do
      expect(a_delete("/projects/3/triggers/7b9148c158980bbd9bcea92c17522d")).to have_been_made
    end

    it "should return information about a deleted trigger" do
      expect(@trigger.created_at).to eq("2015-12-23T16:25:56.760Z")
      expect(@trigger.token).to eq("7b9148c158980bbd9bcea92c17522d")
    end
  end

  describe ".trigger_build" do
    before do
      @old_endpoint = Gitlab.endpoint
      @endpoint = URI(Gitlab.endpoint)
      @endpoint.path = ''
    end

    after do
      Gitlab.endpoint = @old_endpoint
      Gitlab.private_token = 'secret'
    end

    context "when endpoint is not set" do
      it "should raise Error::MissingCredentials" do
        Gitlab.endpoint = nil
        expect do
          Gitlab.trigger_build(3, "7b9148c158980bbd9bcea92c17522d", "master", {a: 10})
        end.to raise_error(Gitlab::Error::MissingCredentials, 'Please set an endpoint to API')
      end
    end

    context "when endpoint is set" do
      before do
        stub_request(:post, "#{@endpoint}/projects/3/trigger/builds").
          to_return(body: load_fixture('trigger_build'), status: 201)
      end

      context "when private_token is not set" do
        it "should not raise Error::MissingCredentials" do
          Gitlab.private_token = nil
          expect { Gitlab.trigger_build(3, "7b9148c158980bbd9bcea92c17522d", "master", {a: 10}) }.to_not raise_error
        end
      end

      context "without variables" do
        before do
          @trigger = Gitlab.trigger_build(3, "7b9148c158980bbd9bcea92c17522d", "master")
        end
        it "should get the correct resource" do
          expect(a_request(:post, "#{@endpoint}/projects/3/trigger/builds").
            with(body: {
              token: "7b9148c158980bbd9bcea92c17522d",
              ref: "master"
            })).to have_been_made
        end

        it "should return information about the triggered build" do
          expect(@trigger.id).to eq(8)
        end
      end

      context "with variables" do
        before do
          @trigger = Gitlab.trigger_build(3, "7b9148c158980bbd9bcea92c17522d", "master", {a: 10})
        end
        it "should get the correct resource" do
          expect(a_request(:post, "#{@endpoint}/projects/3/trigger/builds").
            with(body: {
              token: "7b9148c158980bbd9bcea92c17522d",
              ref: "master",
              variables: {a: "10"}
            })).to have_been_made
        end

        it "should return information about the triggered build" do
          expect(@trigger.id).to eq(8)
          expect(@trigger.variables.a).to eq("10")
        end
      end
    end
  end
end
