//
//  ContentView.swift
//  SwiftUINews
//
//  Created by Hoo on 2021/6/3.
//

import SwiftUI

struct ContentView: View {
    @State var needLogin = true
    @State var browsing = false
    @State var url: String = ""
    @State var title: String = ""
    @State var image: String = ""
    @State var time: String = ""
    @State var isStar: Bool = false
    var body: some View {
        ZStack{
            if needLogin {
                LoginView(needLogin: self.$needLogin)
            }
            else {
                if (!browsing) {
                    NewsView(browsing: self.$browsing, url: self.$url, title: self.$title, image: self.$image, time: self.$time, isStar: self.$isStar)
                }
                else {
                    NewsWebView(browsing: self.$browsing, url: self.$url, title: self.$title, image: self.$image, time: self.$time, isStar: self.$isStar)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
