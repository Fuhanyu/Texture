//
//  ASViewController.m
//  AsyncDisplayKit
//
//  Created by Huy Nguyen on 16/09/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "ASViewController.h"
#import "ASAssert.h"
#import "ASDimension.h"
#import "ASDisplayNode+FrameworkPrivate.h"
#import "ASDisplayNode+Beta.h"

@implementation ASViewController
{
  BOOL _ensureDisplayed;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  ASDisplayNodeAssert(NO, @"ASViewController requires using -initWithNode:");
  return [self initWithNode:[[ASDisplayNode alloc] init]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  ASDisplayNodeAssert(NO, @"ASViewController requires using -initWithNode:");
  return [self initWithNode:[[ASDisplayNode alloc] init]];
}

- (instancetype)initWithNode:(ASDisplayNode *)node
{
  if (!(self = [super initWithNibName:nil bundle:nil])) {
    return nil;
  }
  
  ASDisplayNodeAssertNotNil(node, @"Node must not be nil");
  ASDisplayNodeAssertTrue(!node.layerBacked);
  _node = node;
  
  return self;
}

- (void)loadView
{
  ASDisplayNodeAssertTrue(!_node.layerBacked);
  self.view = _node.view;
}

- (void)viewDidLayoutSubviews
{
  if (_ensureDisplayed && self.neverShowPlaceholders) {
    _ensureDisplayed = NO;
    [self.node recursivelyEnsureDisplaySynchronously:YES];
  }
  [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [_node measureWithSizeRange:[self nodeConstrainedSize]];

  _ensureDisplayed = YES;
  [_node recursivelyFetchData];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    [self.node transitionLayoutWithSizeRange:ASSizeRangeMake(size, size) animated:[context isAnimated]];
  } completion:nil];
}

// MARK: - Layout Helpers

- (ASSizeRange)nodeConstrainedSize
{
  CGSize viewSize = self.view.bounds.size;
  return ASSizeRangeMake(viewSize, viewSize);
}

- (ASInterfaceState)interfaceState
{
  return _node.interfaceState;
}

@end
