export module trello {
  export def current_sprint [] {
    let sprint_card_name = ^npx trello card:list --board="Dev / 開発スプリント" --list="Working"
        | lines
        | where {|| $in =~ "Sprint"}
        | parse "{name} (ID: {id}"
        | get name
        | get 0

    get_card_code "Dev / 開発スプリント" "Working" $sprint_card_name
  }

  export def fzf_working_cards [] {
    let res = ^npx trello card:list --board="Dev / 開発スプリント" --list="Working" 
    | parse "{name} (ID: {id})"
    
    let chosen_name = $res | fzflist name | get name

    get_card_code "Dev / 開発スプリント" "Working" $chosen_name
  }
  export def fzf_reviewing_cards [] {
    let res = ^npx trello card:list --board="Dev / 開発スプリント" --list="Reviewing/Testing/Waiting updates" 
    | parse "{name} (ID: {id})"
    
    let chosen_name = $res | fzflist name | get name

    get_card_code "Dev / 開発スプリント" "Reviewing/Testing/Waiting updates" $chosen_name
  }

  export def fzf_my_cards [] {
    let res = ^npx trello card:assigned-to | parse "{name} (ID: {id}, Board: {board}, List: {list})"

    let chosen = $res | fzflist name 
    get_card_code $chosen.board $chosen.list $chosen.name
  }


  def get_card_code [board_name: string, list_name :string, card_name: string] {
    let card = ^npx trello card:show $"--board=($board_name)" $"--list=($list_name)" $"--card=($card_name)" --format=json | from json

    $card
    | get "url"
    | path split
    | get 3
  }
}
