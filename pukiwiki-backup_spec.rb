require "./pukiwiki-backup.rb"

describe SFTP do
 before { @sftp = SFTP.new }

  context "SFTPサーバにログインする" do
    subject { @sftp }
    it(:empty?) { should be_true }
  end

  context "ディレクトリの一覧を配列で受け取る" do
    subject { @sftp.getDir }
    it(:empty?) {should be_true}
  end
end