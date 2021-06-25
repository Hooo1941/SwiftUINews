//
//  NewsWebView.swift
//  SwiftUINews
//
//  Created by Hoo on 2021/6/17.
//

import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    let request: URLRequest
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}

struct NewsWebView: View {
    @Environment(\.managedObjectContext) var moc
    @State var showingAlert = false
    @Binding var browsing: Bool
    @Binding var url: String
    @Binding var title: String
    @Binding var image: String
    @Binding var time: String
    @Binding var isStar: Bool
    var body: some View {
        VStack {
            HStack{
            Button(action: {browsing = false}) {
                Text("返回")
            }.offset(x: -170, y: 0)
            if (!isStar)
            {
                Button(action: {
                let star = Star(context: self.moc)
                star.title = title
                star.timestamp = Date.init()
                star.image = image
                star.time = time
                star.url = url
                try? self.moc.save()
                isStar = true
                }) {
                Image(systemName: "star")
                }.offset(x: 170, y: 0)
            }
            if (isStar)
            {
                Button(action: {self.showingAlert = true}) {
                Image(systemName: "star.fill")
                }.offset(x: 170, y: 0)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("提示"),
                          message: Text("请在收藏界面长按新闻删除"),
                          dismissButton: .default(Text("OK")))
                }
            }
            }
            WebView(request: URLRequest(url: URL(string: url)!))
        }
    }
}

struct NewsWebView_Previews: PreviewProvider {
    static var previews: some View {
        NewsWebView(browsing: .constant(true), url: .constant("www.baidu.com"), title: .constant(""), image: .constant(""), time: .constant(""), isStar: .constant(false)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
