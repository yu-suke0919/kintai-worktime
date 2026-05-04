require 'rails_helper'

RSpec.describe Employee, type: :model do
  let(:user1) { FactoryBot.create(:employee) }
  describe '新規登録' do
    it 'FactoryBotでのユーサー登録が可能かどうか' do
      expect(user1).to be_valid
    end
  end
end




# require 'rails_helper'

# RSpec.describe Article, type: :model do
#   let(:user_a) { FactoryBot.create(:user, name: 'ユーザーA', email: 'emailA') }
#   let(:article1) { FactoryBot.create(:article, user: user_a, title: 'title1') }
#   let(:article1_dup) { FactoryBot.build(:article, user: user_a, title: 'title1') }
#   let(:article2) { FactoryBot.build(:article, user: user_a, title: 'title2') }
#   describe 'title' do
#     it 'タイトルが重複していなければ、どちらもsave可能' do
#       expect(article1).to be_valid
#       expect(article2.save).to eq true
#     end

#     it 'タイトルが重複している場合、後者はセーブ不可' do
#       expect(article1).to be_valid
#       expect(article1_dup.save).to eq false
#     end
#   end
# end
