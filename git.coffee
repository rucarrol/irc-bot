module.exports = (robot) ->
  github = "https://api.github.com/repos/librenms/librenms/"
  robot.respond /latest (version|commit)/i, (msg) ->
    msg.http("#{github}branches/master")
      .get() (err, res, body) ->
        json     = JSON.parse(body)
        sha      = json['commit']['sha']
        message  = json['commit']['commit']['message']
        date     = json['commit']['commit']['author']['date']
        msg.send "Latest commit is #{sha} (#{message}) at #{date}"
  robot.respond /compare (version|commit|[ ]*)([ ]*)(.*)/i, (msg) ->
    sha = msg.match[3]
    msg.send "Checking SHA #{sha}"
    compare = "#{github}compare/master...#{sha}"
    msg.http(compare)
      .get() (err, res, body) ->
        json   = JSON.parse(body)
        behind = json['behind_by']
        message = json['message']
        if message is "Not Found"
          msg.send "That commit doesn't appear to be one of ours"
        else if behind > 0
          msg.send "You are behind by #{behind} commits"
        else
          msg.send "You seem to be upto date, nice work :)"
