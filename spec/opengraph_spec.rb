require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe OpenGraph do
  let(:rotten){ File.open(File.dirname(__FILE__) + '/examples/rottentomatoes.html').read }
  let(:partial){ File.open(File.dirname(__FILE__) + '/examples/partial.html').read }
  
  describe '.parse' do
    it 'should return false if there isnt valid Open Graph info' do
      OpenGraph.parse("").should be_false
      OpenGraph.parse(partial).should be_false
    end
    
    it 'should otherwise return an OpenGraph::Object' do
      OpenGraph.parse(rotten).should be_kind_of(OpenGraph::Object)
    end
    
    context ' without strict mode' do
      subject{ OpenGraph.parse(partial, false) }
      
      it { should_not be_false }
      it { subject.title.should == 'Partialized' }
    end
  end
  
  describe '.fetch' do
    it 'should fetch from the specified URL' do
      stub_request(:get, 'http://www.rottentomatoes.com/m/1217700-kick_ass/').to_return(:body => rotten)
      OpenGraph.fetch('http://www.rottentomatoes.com/m/1217700-kick_ass/').title.should == 'Kick-Ass'
      WebMock.should have_requested(:get, 'http://www.rottentomatoes.com/m/1217700-kick_ass/')
    end
    
    it 'should catch errors' do
      stub_request(:get, 'http://example.com').to_return(:status => 404)
      OpenGraph.fetch('http://example.com').should be_false
      RestClient.should_receive(:get).with('http://example.com').and_raise(SocketError)
      OpenGraph.fetch('http://example.com').should be_false
    end
  end
end

describe OpenGraph::Object do
  let(:rotten){ File.open(File.dirname(__FILE__) + '/examples/rottentomatoes.html')}
  
  context ' a Rotten Tomatoes Movie' do
    subject{ OpenGraph.parse(rotten) }
    
    it 'should have the title' do
      subject.title.should == "Kick-Ass"
    end
    
    it 'should be a product' do
      subject.schema.should == 'product'
      subject.should be_product
      subject.should_not be_person
    end
    
    it 'should be a movie' do
      subject.type.should == 'movie'
      subject.should be_movie
      subject.should_not be_tv_show
    end
    
    it 'should be valid' do
      subject.should be_valid
      subject['type'] = nil
      subject.should_not be_valid
    end
  end
end
