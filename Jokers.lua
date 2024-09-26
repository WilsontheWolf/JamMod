--- STEAMODDED HEADER
--- MOD_NAME: JamMod
--- MOD_ID: JamMod
--- MOD_AUTHOR: [WilsontheWolf]
--- MOD_DESCRIPTION: JellyMod for modern SMODS
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0919a]
--- PREFIX: jam
if JokerDisplay then
    assert(SMODS.load_file("joker_display_definitions.lua"))()
end


SMODS.Atlas {
  key = "Jokers",
  path = "Jokers.png",
  px = 71,
  py = 95
}


SMODS.Joker {
  key = 'double_vision',
  loc_txt = {
    name = 'Double Vision',
    text = {
      "All cards are",
      "considered",
      "{C:attention}2s{}",
    }
  },
  atlas = 'Jokers',
  pos = { x = 8, y = 2 },
  rarity = 3,
  cost = 10,
  blueprint_compat = false
}

SMODS.Joker {
    key = 'prosopagnosia',
    loc_txt = {
        name = 'Prosopagnosia',
        text = {
          "{C:red}NO{} cards are",
          "considered",
          "{C:attention}face{} cards",
        }
    },
    atlas = 'Jokers',
    pos = {
      x = 7,
      y = 2
    },
    rarity = 1,
    cost = 5,
    blueprint_compat = false
}

SMODS.Joker {
    key = 'pessimist',
    config = {extra = 2},
    loc_txt = {
        name = 'Pessimist',
        text = {
          "Sell this card to apply",
          "{C:dark_edition}negative{} to a random Joker.",
          "Permanent {C:blue}-#1#{} hands.",
          "{C:inactive}({C:attention}Destroys{C:inactive} itself when blind selected){}"
        }
    },
    atlas = 'Jokers',
    pos = {
      x = 6,
      y = 2
    },
    rarity = 3,
    cost = 10,
    calculate = function(self, card, context)
      if context.selling_self then
        local eligible = {}
        for k, v in pairs(G.jokers.cards) do
            if v.ability.set == 'Joker' and (not v.edition) and v ~= card and v ~= context.blueprint_card then
                table.insert(eligible, v)
            end
        end
        if #eligible == 0 then
          return nil, true
        end
        local eligible_card = pseudorandom_element(eligible, pseudoseed("jam_pessimist"))
        eligible_card:set_edition({negative = true}, true)
        G.hand:change_size(-card.ability.extra)
        return nil, true
      elseif context.setting_blind and not self.getting_sliced and not context.blueprint then
        G.E_MANAGER:add_event(
          Event({
            func = function()
              card:start_dissolve()
              return true 
            end 
          })
        )
      end
    end,
    loc_vars = function(self, info_queue, center)
      info_queue[#info_queue + 1] = {
        key = 'e_negative_consumable', 
        set = 'Edition',
        config = {extra = 1}
      }
      return { vars = { center.ability.extra } }
    end,
    blueprint_compat = true
}

SMODS.Joker {
    key = 'one_more_time',
    config = {
        extra = 0
    },
    loc_txt = {
        name = "One More Time!",
        text = {
          "Sell this card to",
          "Add your previous hand to current score",
          "(Currently {C:blue,E:1,S:1}#1#{})",
        },    
    },
    atlas = 'Jokers',
    pos = {
      x = 1,
      y = 3
    },
    rarity = 1,
    cost = 8,
    calculate = function(self, card, context)
      if context.selling_self and G.STATE == G.STATES.SELECTING_HAND then
        G.E_MANAGER:add_event(Event({
            func = function()
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                  message = "+" .. number_format(G.GAME.round_resets.jam_last_chips or 0)
                });
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
          blocking = true,
          trigger = 'ease',
          ref_table = G.GAME,
          ref_value = 'chips',
          ease_to = G.GAME.chips + math.floor(G.GAME.round_resets.jam_last_chips or 0),
          delay = 0.2,
          func = (function(t) return math.floor(t) end)
        }))

        G.E_MANAGER:add_event(Event({
          func = (function(t) if G.GAME.chips >  G.GAME.blind.chips then G.STATE = G.STATES.NEW_ROUND 
          G.STATE_COMPLETE = false
          end
          return true end)
        }))
        
        return nil, true
      end
    end,
    loc_vars = function(self, info_queue, card)
      return { vars = { G.GAME.round_resets.jam_last_chips or 0 } }
    end,
    blueprint_compat = true
}

SMODS.Joker {
    key = 'tarlton',
    config = {
        extra = 0
    },
    loc_txt = {
        name = "Tarlton",
        text = {
          "Copies the effects of",
          "all other {C:attention}Jokers{}",
          "In your possession.",
          "{C:inactive}(must be compatible){}"
        },
    },
    atlas = 'Jokers',
    pos = {
      x = 1,
      y = 2
    },
    soul_pos = {
      x = 9,
      y = 3
    },
    rarity = 4,
    cost = 20,
    calculate = function(self, card, context)
      if not context.blueprint then
        local other_joker = nil
        local final_ret = nil
        for i=1,#G.jokers.cards do
            other_joker = G.jokers.cards[i]
            if other_joker and other_joker.ability.name ~= card.ability.name and other_joker.config.center.blueprint_compat then
                context.blueprint_card = card
                context.blueprint = 1
                local other_joker_ret = other_joker:calculate_joker(context)
            end
        end
        if final_ret then
            return final_ret
        end
      end
    end,
    blueprint_compat = false
}

SMODS.Joker {
    key = 'greedy_pot',
    loc_txt = {
        name = 'Greedy Pot',
        text = {
          "After play or discard, always draw", 
          "{C:attention}#1# more{} cards than you would otherwise.",
        }
    },
    config = {extra = 2},
    atlas = 'Jokers',
    pos = {
        x = 6,
        y = 1
    },
    rarity = 3,
    cost = 10,
    loc_vars = function(self, info_queue, center)
      return { vars = { center.ability.extra } }
    end,
    blueprint_compat = false
}
