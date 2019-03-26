Pod::Spec.new do |s|
	s.name = 'LKImageKit'
	s.version = '5.4.1'
	s.description = 'LKImageKit: a high-performance image framework'
	s.homepage = 'https://github.com/Tencent/LKImageKit'
	s.license = 'BSD 3-Clause'
	s.summary = 'LKImageKit'
	s.authors = { 'kelingjie1' => 'kelingjie1@qq.com' }
	s.source = { :git => 'https://github.com/Tencent/LKImageKit.git', :tag => s.version.to_s }
	s.requires_arc = true
	s.ios.deployment_target = '8.0'
	s.source_files = 'LKImageKit/LKImageKit.h','LKImageKit/Core/**/*.{h,m}','LKImageKit/Components/**/*.{h,m,mm}'
	s.libraries = 'c++.1'
end