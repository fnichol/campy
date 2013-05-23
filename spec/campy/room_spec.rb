# -*- encoding: utf-8 -*-

# Currently there no support for SimpleCov in Rubinus, see:
# http://donttreadonme.co.uk/rubinius/2012/02/22.html#message_243
unless defined?(RUBY_ENGINE) && RUBY_ENGINE == "rbx"
  require 'simplecov'
  SimpleCov.adapters.define 'gem' do
    command_name 'Specs'

    add_filter '.gem/'
    add_filter '/spec/'

    add_group 'Binaries', '/bin/'
    add_group 'Libraries', '/lib/'
  end
  SimpleCov.start 'gem'
end

require 'minitest/autorun'
require 'webmock/minitest'
require 'campy/room'

describe Campy::Room do
  WRAPPED_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
      SocketError, OpenSSL::SSL::SSLError, Errno::ECONNREFUSED]

  let(:opts) do
    { :account => 'zubzub', :token => 'yepyep',
      :room => 'myroom', :ssl => true }
  end

  let(:stub_rooms!) do
    stub_request(:get, "https://yepyep:X@zubzub.campfirenow.com/rooms.json").
      with(:headers => {'Content-Type' => 'application/json'}).
      to_return(:status => 200, :body => fixture("rooms"), :headers => {})
  end

  let(:stub_rooms_no_room!) do
    stub_request(:get, "https://yepyep:X@zubzub.campfirenow.com/rooms.json").
      with(:headers => {'Content-Type' => 'application/json'}).
      to_return(:status => 200, :body => fixture("no_rooms"), :headers => {})
  end

  let(:stub_rooms_invalid_token!) do
    stub_request(:get, "https://yepyep:X@zubzub.campfirenow.com/rooms.json").
      with(:headers => {'Content-Type' => 'application/json'}).
      to_return(:status => 401, :body => "HTTP Basic: Access denied.\n",
                :headers => {})
  end

  def stub_rooms_error!(error)
    stub_request(:get, "https://yepyep:X@zubzub.campfirenow.com/rooms.json").
      with(:headers => {'Content-Type' => 'application/json'}).
      to_raise(error)
  end

  def stub_speak!(msg, type = 'TextMessage')
    stub_request(:post, "https://yepyep:X@zubzub.campfirenow.com/room/123456/speak.json").
      with(:headers => {'Content-Type' => 'application/json'},
           :body => {:message => {:body => msg, :type => type}}).
      to_return(:status => 201, :headers => {},
                :body => fixture("speak").sub(/@@MESSAGE@@/, msg))
  end

  def stub_speak_not_found!(msg, type = 'TextMessage')
    stub_request(:post, "https://yepyep:X@zubzub.campfirenow.com/room/123456/speak.json").
      with(:headers => {'Content-Type' => 'application/json'},
           :body => {:message => {:body => msg, :type => type}}).
      to_return(:status => 404, :headers => {}, :body => "Not Found")
  end

  def stub_speak_error!(error)
    stub_request(:post, "https://yepyep:X@zubzub.campfirenow.com/room/123456/speak.json").
      with(:headers => {'Content-Type' => 'application/json'}).
      to_raise(error)
  end

  def fixture(name)
    File.read(File.dirname(__FILE__) + "/../fixtures/webmock_#{name}.txt")
  end

  describe "#initialize" do
    it "takes a hash of campfire configuration" do
      room = Campy::Room.new(opts)

      room.account.must_equal 'zubzub'
      room.room.must_equal    'myroom'
    end

    it "defaults to SSL mode enabled" do
      opts.delete(:ssl)
      room = Campy::Room.new(opts)

      room.ssl.must_equal true
    end
  end

  describe "#room_id" do
    let(:subject) { Campy::Room.new(opts) }

    it "returns the room_id set in the initializer if it is provided" do
      room_with_id = Campy::Room.new(opts.merge(:room_id => 654321))

      room_with_id.room_id.must_equal 654321
    end

    it "fetches the room id from the API" do
      stub_rooms!

      subject.room_id.must_equal 666666
    end

    it "raises NotFound if no room is found" do
      stub_rooms_no_room!

      proc { subject.room_id }.must_raise(Campy::Room::NotFound)
    end

    it "raises ConnectionError if the token is invalid" do
      stub_rooms_invalid_token!

      proc { subject.room_id }.must_raise(Campy::Room::ConnectionError)
    end

    WRAPPED_ERRORS.each do |error|
      it "wraps #{error} and raises a ConnectionError" do
        stub_rooms_error!(error)

        proc { subject.room_id }.must_raise(Campy::Room::ConnectionError)
      end
    end
  end

  describe "#speak" do
    let(:subject) { Campy::Room.new(opts) }

    before do
      # stub out #room_id since we don't care about this API call
      def subject.room_id ; 123456 ; end
    end

    it "calls the speak API with a message" do
      stub = stub_speak!("talking about talking")
      subject.speak "talking about talking"

      assert_requested(stub)
    end

    it "returns true when message is delivered" do
      stub = stub_speak!("talking about talking")

      subject.speak("talking about talking").must_equal true
    end

    it "raises a ConnectionError when API does not return HTTP 201" do
      stub_speak_not_found!("nope")

      proc { subject.speak "nope" }.must_raise(Campy::Room::ConnectionError)
    end

    WRAPPED_ERRORS.each do |error|
      it "wraps #{error} and raises a ConnectionError" do
        stub_speak_error!(error)

        proc { subject.speak "nope" }.must_raise(Campy::Room::ConnectionError)
      end
    end
  end

  describe "#paste" do
    let(:subject) { Campy::Room.new(opts) }

    before do
      # stub out #room_id since we don't care about this API call
      def subject.room_id ; 123456 ; end
    end

    it "calls the paste API with a message" do
      stub = stub_speak!("big ol long paste\nwith newlines", "PasteMessage")
      subject.paste "big ol long paste\nwith newlines"

      assert_requested(stub)
    end

    it "returns true when message is delivered" do
      stub = stub_speak!("big ol long paste\nwith newlines", "PasteMessage")

      subject.paste("big ol long paste\nwith newlines").must_equal true
    end

    it "raises a ConnectionError when API does not return HTTP 201" do
      stub_speak_not_found!("nope", "PasteMessage")

      proc { subject.paste "nope" }.must_raise(Campy::Room::ConnectionError)
    end

    WRAPPED_ERRORS.each do |error|
      it "wraps #{error} and raises a ConnectionError" do
        stub_speak_error!(error)

        proc { subject.paste "nope" }.must_raise(Campy::Room::ConnectionError)
      end
    end
  end

  describe "#play" do
    let(:subject) { Campy::Room.new(opts) }

    before do
      # stub out #room_id since we don't care about this API call
      def subject.room_id ; 123456 ; end
    end

    it "calls the play API with a sound" do
      stub = stub_speak!("tada", "SoundMessage")
      subject.play "tada"

      assert_requested(stub)
    end

    it "returns true when message is delivered" do
      stub = stub_speak!("tada", "SoundMessage")

      subject.play("tada").must_equal true
    end

    it "raises a ConnectionError when API does not return HTTP 201" do
      stub_speak_not_found!("nope", "SoundMessage")

      proc { subject.play "nope" }.must_raise(Campy::Room::ConnectionError)
    end

    WRAPPED_ERRORS.each do |error|
      it "wraps #{error} and raises a ConnectionError" do
        stub_speak_error!(error)

        proc { subject.play "tada" }.must_raise(Campy::Room::ConnectionError)
      end
    end
  end
end
