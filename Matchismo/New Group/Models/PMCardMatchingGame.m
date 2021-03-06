//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Pavel on 21.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import "PMCardMatchingGame.h"
#import "PMDeck.h"
#import "PMCard.h"

@interface PMCardMatchingGame()

@property (assign, nonatomic, readwrite) NSInteger score;
@property (strong, nonatomic, readwrite) NSString *roundTextPresentation;
@property (strong, nonatomic) NSMutableArray *cards; // of Card
@property (strong, nonatomic) NSMutableArray *chosenCards; // of Card

@end

typedef enum {
    PMGameTypeTwoCards,
    PMGameTypeThreeCards
} PMGameType;

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;

@implementation PMCardMatchingGame

- (instancetype)initWithCardCount:(NSUInteger)count usingDeck:(PMDeck *)deck {
    
    self = [super init];
    
    if (self) {
        for (int i = 0; i < count; i++) {
            PMCard *card = [deck drawRandomCard];
            if (card) {
                [self.cards addObject: card];
            } else {
                self = nil;
                break;
            }
        }
    }
    
    return self;
}



- (PMCard *) cardAtIndex: (NSUInteger) index {
    
    return (index < [self.cards count]) ? self.cards[index] : nil;
}

- (void) chooseCardAtIndex: (NSUInteger) index {
    
    PMCard *card = [self cardAtIndex: index];
    
    self.roundTextPresentation = [NSString stringWithFormat: @"%@", card.contents];
    
    switch (self.mode) {
            
        case PMGameTypeTwoCards:
            if (!card.isMatched) {
                if (card.isChosen) {
                    card.chosen = NO;
                    self.roundTextPresentation = @"";
                } else {
                    // match against another card
                    for (PMCard *otherCard in self.cards) {
                        if (otherCard.isChosen && !otherCard.isMatched) {
                            int matchScore = [card match: @[otherCard]];
                            if (matchScore) {
                                self.score += matchScore * MATCH_BONUS;
                                card.matched = YES;
                                otherCard.matched = YES;
                                self.roundTextPresentation = [NSString stringWithFormat: @"%@ & %@ matched! %d point bonuses", card.contents, otherCard.contents, matchScore * MATCH_BONUS];
                            } else {
                                self.score -= MISMATCH_PENALTY;
                                otherCard.chosen = NO;
                                self.roundTextPresentation = [NSString stringWithFormat: @"%@ & %@ don’t matched! %d point penalty", card.contents, otherCard.contents, MISMATCH_PENALTY];
                            }
                            break;
                        }
                    }
                    self.score -= COST_TO_CHOOSE;
                    card.chosen = YES;
                }
            }
            break;
            
        case PMGameTypeThreeCards:
             if (!card.isMatched) {
                if (card.isChosen) {
                    card.chosen = NO;
                    if ([self.chosenCards containsObject: card]) {
                        [self.chosenCards removeObject: card];
                    }
                } else {
                    // match against another card
                    
                    for (PMCard *otherCard in self.cards) {
                        if (otherCard.isChosen && !otherCard.isMatched) {
                            
                            if (![self.chosenCards containsObject: otherCard]) {
                                [self.chosenCards addObject: otherCard];
                                
                                self.roundTextPresentation = [self.roundTextPresentation stringByAppendingString: otherCard.contents];
                                
                            } else {
                                continue;
                            }
                            
                            if ([self.chosenCards count] == 2) {
                                
                                int matchScore = [card match: self.chosenCards];
                                
                                if (matchScore) {
                                    self.score += matchScore * MATCH_BONUS;
                                    card.matched = YES;
                                    for (PMCard *chosenCard in self.chosenCards) {
                                        chosenCard.matched = YES;
                                    }
                                    self.roundTextPresentation = [NSString stringWithFormat: @"Matched! %d point bonuses", matchScore * MATCH_BONUS];
                                } else {
                                    self.score -= MISMATCH_PENALTY;
                                    for (PMCard *chosenCard in self.chosenCards) {
                                        chosenCard.chosen = NO;
                                    }
                                    self.roundTextPresentation = [NSString stringWithFormat: @"Don’t match! %d point penalty", MISMATCH_PENALTY];
                                }
                                
                                [self.chosenCards removeAllObjects];
                            }
                        }
                    }
                    
                    self.score -= COST_TO_CHOOSE;
                    card.chosen = YES;
                }
            }
            break;
        default:
            break;
    }
    
    
}

- (NSMutableArray *) cards {
    if (!_cards) {
        _cards = [NSMutableArray array];
    }
    return _cards;
}

- (NSMutableArray *) chosenCards {
    if (!_chosenCards) {
        _chosenCards = [NSMutableArray array];
    }
    return _chosenCards;
}


@end
