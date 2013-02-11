//
//  UECPhotosViewController.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECPhotoAlbumsViewController.h"

#import "UECPhotoAlbumCell.h"

#import "APSDataManager.h"
#import "PhotoAlbum.h"

@interface UECPhotoAlbumsViewController ()

@property (strong, nonatomic) NSArray *photoAlbums;

@end

@implementation UECPhotoAlbumsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Here I need to figure out which photo albums to update. There should not
    // be any point in reloading all of them, even with SDWebImage.
    [self refreshData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Refresh

- (void)refreshData
{
    [[APSDataManager sharedManager] getDataForEntityName:@"PhotoAlbum" coreDataCompletion:^(NSArray *cachedObjects) {
        self.photoAlbums = cachedObjects;
        [self.collectionView reloadData];
    } downloadCompletion:^(BOOL needsReloading, NSArray *downloadedObjects) {
        if (needsReloading) {
            self.photoAlbums = downloadedObjects;
            [self.collectionView reloadData];
        }
    }];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photoAlbums count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Photo Album Cell";
    UECPhotoAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PhotoAlbum *album = self.photoAlbums[indexPath.row];
    cell.titleLabel.text = album.name;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
