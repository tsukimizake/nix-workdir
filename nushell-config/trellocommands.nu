export module trello {
  export def current_sprint [] {
    ^trello2 cards list --board="Dev / 開発スプリント" --list="Working"
        | from json
        | where {|card| $card.name =~ "Sprint"}
        | get 0
        | get shortLink
  }

  export def fzf_working_cards [] {
    let res = ^trello2 cards list --board="Dev / 開発スプリント" --list="Working"
    | from json

    $res | fzflist name | get shortLink
  }
  export def fzf_reviewing_cards [] {
    let res = ^trello2 cards list --board="Dev / 開発スプリント" --list="Reviewing/Testing/Waiting updates"
    | from json

    $res | fzflist name | get shortLink
  }

  export def fzf_my_cards [] {
    let res = ^trello2 cards assigned --me
    | from json
    | where {|card| not ($card.list.name =~ "Done" or $card.list.name =~ "改修完了")}

    $res | fzflist name | get shortLink
  }
}
