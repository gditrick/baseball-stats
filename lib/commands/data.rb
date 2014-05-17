module BaseballStats
  BATTING_FILE_HEADERS=%i(playerID yearID league teamID G AB R H 2B 3B HR RBI SB CS)
  BATTING_MAPPINGS={
    playerID:  :player_id,
    yearID:    :year,
    league:    :league_id,
    teamID:    :team_id,
    G:         :games,
    AB:        :at_bats,
    R:         :runs,
    H:         :hits,
    :"2B" =>   :doubles,
    :"3B" =>   :triples,
    HR:        :home_runs,
    RBI:       :rbi,
    SB:        :stolen_bases,
    CS:        :caught_stealing
  }
  PLAYER_FILE_HEADERS=%i(playerID birthYear nameFirst nameLast)
  PLAYER_MAPPINGS={
    playerID:  :id,
    birthYear: :birth_year,
    nameFirst: :first_name,
    nameLast:  :last_name
  }
  class Data < Thor
    desc 'load', 'Load in new data'
    def load_new(in_config)
      processed_files = []
      data_files      = Dir.glob(File.join(File.expand_path(File.join('..', '..', '..', in_config.path), __FILE__), "*#{in_config.ext}"))
      data_files.each do |file|
        t = RemoteTable.new file
        headers =  t.headers
        if headers.map(&:to_sym).sort == PLAYER_FILE_HEADERS.sort
          bad_records = []
          processed_files << data_files.delete(file)
          t = RemoteTable.new file
          t.rows.each do |r|
            attrs = map_row(PLAYER_MAPPINGS, r)
            if (p = Player[attrs[:id]])
              attrs.delete(:id)
              p.update(attrs)
            else
              Player.insert(attrs) unless attrs[:id].blank?
              if attrs[:id].blank?
                headers << 'errorMsg' unless headers.include?('errorMsg')
                r['errorMsg'] ||= []
                r['errorMsg'] |= ['Missing playerID']
                bad_records << r if attrs[:id].blank?
              end
            end
          end 
          unless bad_records.empty?
          end
        end
      end
      data_files.each do |file|
        t = RemoteTable.new file
        if t.headers.map(&:to_sym).sort == BATTING_FILE_HEADERS.sort
          bad_records = []
          processed_files << data_files.delete(file)
          t = RemoteTable.new file
          t.rows.each do |r|
            attrs = map_row(BATTING_MAPPINGS, r)
            if (p = Player[attrs[:player_id]])
              bs = BattingStat.new(attrs)
              p.add_batting_stat(bs)
            else
              headers << 'errorMsg' unless headers.include?('errorMsg')
              r['errorMsg'] ||= []
              r['errorMsg'] |= ['No matching player']
              bad_records << r if attrs[:id].blank?
            end
          end
          unless bad_records.empty?
          end
        end
      end
      processed_files
    end

    private

    def map_row(mappings, row)
      row.inject({}){|m,(k,v)| m[mappings[k.to_sym]] = v; m}
    end
  end
end
