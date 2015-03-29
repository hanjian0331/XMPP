//
//  HJProfileViewController.m
//  XMPP
//
//  Created by HJ on 15/3/28.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "HJEditProfileViewController.h"

@interface HJProfileViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,HJEditProfileViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;//账号
@property (weak, nonatomic) IBOutlet UILabel *orgnameLabel;//公司
@property (weak, nonatomic) IBOutlet UILabel *orgunitLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;//职位
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation HJProfileViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = @"个人信息";
    [self loadVCard];
}

- (void)loadVCard
{
    XMPPvCardTemp *myvCardTemp = [HJXMPPTool sharedHJXMPPTool].vCard.myvCardTemp;
    if (myvCardTemp.photo) {
        self.headView.image = [UIImage imageWithData: myvCardTemp.photo];
    }
    self.nicknameLabel.text = myvCardTemp.nickname;
    self.numberLabel.text = [HJUserInfo sharedHJUserInfo].user;
    self.orgnameLabel
    .text = myvCardTemp.orgName;
    if (myvCardTemp.orgUnits.count > 0) {
        self.orgunitLabel.text = [myvCardTemp.orgUnits firstObject];
    }
    self.titleLabel.text = myvCardTemp.title;
    // myvCardTemp.telecomsAddresses 这个get方法没有对电子名片的xml的数据进行解析
    //    self.phoneLable.text = myvCardTemp.telecomsAddresses;
    self.phoneLabel.text = myvCardTemp.note;
    self.emailLabel.text = myvCardTemp.mailer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSInteger tag = cell.tag;
    if (tag == 2) {
        return;
    }
    if (tag == 0) {//选择图片
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
        [sheet showInView:self.view];
    }else{//tag =1，跳到下个控制器
        [self performSegueWithIdentifier:@"EditVCardSegue" sender:cell];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //获取编辑个人信息的控制器
    id dest = segue.destinationViewController;
    if ([dest isKindOfClass:[HJEditProfileViewController class]]) {
        HJEditProfileViewController *edit = (HJEditProfileViewController *)dest;
        edit.myCell = sender;
        edit.delegate = self;
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {//取消
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;

    if (buttonIndex == 0) {//相机
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{//相册
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.headView.image = image;
    //隐藏当前的模态窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self editProfileViewControllerDidSave];
}

#pragma mark 编辑个人信息代理
- (void)editProfileViewControllerDidSave
{
    XMPPvCardTemp *vCardTemp = [HJXMPPTool sharedHJXMPPTool].vCard.myvCardTemp;
    vCardTemp.photo = UIImagePNGRepresentation(self.headView.image);
    vCardTemp.nickname = self.nicknameLabel
    
    .text;
    vCardTemp.orgName = self.orgnameLabel.text;
    if (self.orgunitLabel.text.length > 0) {
        vCardTemp.orgUnits = @[self.orgunitLabel.text];
    }
    vCardTemp.title = self.titleLabel.text;
    vCardTemp.note = self.phoneLabel.text;
    vCardTemp.mailer = self.emailLabel.text;
    
    [[HJXMPPTool sharedHJXMPPTool].vCard updateMyvCardTemp:vCardTemp];
}
@end
