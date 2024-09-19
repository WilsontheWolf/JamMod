--- STEAMODDED HEADER
--- MOD_NAME: JamMod
--- MOD_ID: JamMod
--- MOD_AUTHOR: []
--- MOD_DESCRIPTION: JellyMod for modern SMODS
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- PREFIX: JamMod


SMODS.Atlas {
  key = "Jokers",
  path = "Jokers.png",
  px = 71,
  py = 95
}


SMODS.Joker {
  key = 'jokertest',
  loc_txt = {
    name = 'Test Joker',
    text = {
      "{C:mult}+#1# {} Mult"
    }
  },
  config = { extra = { mult = 4 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult } }
  end,
  rarity = 1,
  atlas = 'Jokers',
  pos = { x = 0, y = 0 },
  cost = 2,
  calculate = function(self, card, context)
    if context.joker_main then
      return {
        mult_mod = card.ability.extra.mult,
        message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
      }
    end
  end
}

