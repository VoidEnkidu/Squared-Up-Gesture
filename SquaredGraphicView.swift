//
//  SquaredGraphicView.swift
//  HaidilaoPadV2
//
//  Created by 刘超然 on 17/3/1.
//  Copyright © 2017年 Hoperun. All rights reserved.
//

import UIKit
protocol SquaredGraphicDelegate {
	func lockPathAndisMoreThanFour(_ lockPath : String,_ isMoreThanFour : Bool)
}
class SquaredGraphicView: UIView {
	//用来记录手指当前位置
	var currentP : CGPoint?
	//连接点数大于4个的标识
	var isTrailLegal : Bool = false
	
	var delegate : SquaredGraphicDelegate?
	
	init(frame: CGRect,backgroundColor : UIColor?) {
		super.init(frame: frame)
		self.setupUI(backgroundColor)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
//	required init?(coder aDecoder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
	
	/// 设置UI
	private func setupUI(_ backgroundColor : UIColor?){
		//根据外部传入的背景颜色来做设置
		if let background = backgroundColor {
			self.backgroundColor = background
		}else{
			self.backgroundColor = UIColor.clear
		}
		self.isUserInteractionEnabled = true
		for index in 0..<9{
			let btn = UIButton()
			btn.setBackgroundImage(UIImage(named:"tuoyuanhui"), for: UIControlState.normal)
			btn.setBackgroundImage(UIImage(named:"tuoyuanhongdaquan"), for: UIControlState.highlighted)
			btn.setBackgroundImage(UIImage(named:"tuoyuanhong"), for: UIControlState.selected)
			btn.tag = index
			btn.isUserInteractionEnabled = false
			self.addSubview(btn)
		}
	}
	/// 九宫格布局
	override func layoutSubviews() {
		super.layoutSubviews()
		let btnW = 79
		let btnH = 79
		let totalColum = 3
		let margin = (self.frame.size.width - CGFloat(totalColum * btnW)) / CGFloat(totalColum + 1)
		for index in 0..<self.subviews.count {
			let btn = self.subviews[index]
			let col = index % totalColum
			let row = index / totalColum
			let btnX = margin + CGFloat(col) * (CGFloat(btnW) + margin)
			let btnY = margin + CGFloat(row) * (CGFloat(btnH) + margin)
			btn.frame = CGRect(x: btnX, y: btnY, width: CGFloat(btnW), height: CGFloat(btnH))
		}
	}
	
	//MARK: - 触摸方法
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.currentP = nil
		//获得触摸点
		for touch in touches{
			let p = touch.location(in: touch.view)
			buttonsWithPoint(p)
		}
		//刷新
		self.setNeedsDisplay()
	}
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		//获得触摸点
		for touch in touches{
			let p = touch.location(in: touch.view)
			self.currentP = p
			buttonsWithPoint(p)
		}
		//刷新
		self.setNeedsDisplay()
		
	}
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		var pwd = ""
		for i in 0..<selectedButtons.count{
			let btn = selectedButtons[i]
			pwd = pwd + "\(btn.tag)"
		}
		//连接点大于4个
		if pwd.characters.count >= 4{
			isTrailLegal = true
		}else{
			isTrailLegal = false
			//TODO:错误情况原先设置过按钮换图片,现阶段暂时先删除,等待需求
		}
		delegate?.lockPathAndisMoreThanFour(pwd, isTrailLegal)
		self.currentP = selectedButtons.last?.center
		//刷新
		self.setNeedsDisplay()
		//防止密码错误之后线还没消失,用户还能连线
		self.isUserInteractionEnabled = false
		
		//改变所有需要连线的button图片状态
		for i in 0..<selectedButtons.count{
			let btn = selectedButtons[i]
			btn.isHighlighted = false
			btn.isSelected = true
		}
		//延迟1.5秒清空所有连线状态
		DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
			self?.clearDrawTrail()
			self?.isUserInteractionEnabled = true
		}
	}
	
	/// 根据触摸点获得对应位置的按钮
	///
	/// - Parameter point: 触摸点
	private func buttonsWithPoint(_ point : CGPoint){
		for button in self.subviews{
			let btn = button as! UIButton
			//如果包含当前点的话那么返回这个按钮
			if btn.frame.contains(point){
				btn.isHighlighted = true
				if !selectedButtons.contains(btn){
					selectedButtons.append(btn)
				}
			}
		}
	}
	
	/// 绘制完成后,清空绘画痕迹
	private func clearDrawTrail(){
		selectedButtons.removeAll()
		for i in 0..<self.subviews.count{
			let btn = self.subviews[i] as! UIButton
			btn.isHighlighted = false
			btn.isSelected = false
		}
		self.setNeedsDisplay()
	}
	
	/// 绘图
	///
	/// - Parameter rect: 脏矩形
	override func draw(_ rect: CGRect) {
		let path  = UIBezierPath()
		//遍历全部按钮设置path路径
		for index in 0..<selectedButtons.count{
			if index == 0{
				path.move(to: (selectedButtons.first?.center)!)
			}else{
				path.addLine(to: selectedButtons[index].center)
			}
		}
		//连接
		if selectedButtons.count != 0 {
			if let curP = self.currentP{
				path.addLine(to: curP)
			}
		}
		//样式
		path.lineWidth = 8
		path.lineJoinStyle = CGLineJoin.bevel
		//线的颜色
		UIColor.white.set()
		//渲染
		path.stroke()
	}
	//MARK: - 懒加载
	private lazy var selectedButtons : [UIButton] = {
		var buttons = Array<UIButton>()
		return buttons
	}()
}
