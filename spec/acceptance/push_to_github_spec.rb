require_relative '../helpers/Application'
require_relative '../helpers/fake_github'
require_relative '../helpers/environment_helpers'
require_relative '../../Rakefile'

describe 'when the files have been converted' do
  around_in_xyleme_tmpdir(ENV)

  it 'pushing puts the converted files on a Github repo' do
    application_runner = ApplicationRunner.new(github_client, ENV['TMPDIR'])
    application_runner.convert_directories(%w[spec/fixtures/test_files
                                              spec/fixtures/more_test_files])
    application_runner.push_to_remote('git@github.com:org/repo.git')

    expect(github.to_only_have_received_clone_repo('git@github.com:org/repo.git')).to eq true
    expect(github.repo.contents).
        to match_array %W(spec/fixtures/test_files/file_1.html.erb
                          spec/fixtures/test_files/file_2.html.erb
                          spec/fixtures/test_files/images/img_1.png
                          spec/fixtures/more_test_files/file_3.html.erb
                          spec/fixtures/more_test_files/file_4.html.erb
                          spec/fixtures/more_test_files/pdfs/doc_1.pdf
                          .git)
  end

  let(:github_client) { FakeGitAccessor.new(github, ENV['TMPDIR']) }
  let(:github) do
    repo_1 = FakeGitRepo.new('org', 'repo', Directory.new)
    FakeGithub.new(repo_1)
  end
end
