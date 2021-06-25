//
//  ContentView.swift
//  SwiftUINews
//
//  Created by Hoo on 2021/6/2.
//

import SwiftUI
import CoreData

class News:Codable, Identifiable
{
    var title:String = ""
    var path:String = ""
    var passtime:String = ""
    var image:String = ""
}

class NewsResponse:Codable
{
    var code:Int=0
    var result:[News] = []
    var message:String = ""
}

struct WebImageView: View {
    @State private var uiImage: UIImage? = nil
    let placeholderImage = UIImage(systemName: "photo")
    var imageUrl: String
   
    var body: some View {
        Image(uiImage: self.uiImage ?? placeholderImage!)
//            .resizable()
            .onAppear(perform: downloadWebImage)
    }
   
    func downloadWebImage() {
        guard let url = URL(string: imageUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                self.uiImage = image
            } else {
                print("error: \(String(describing: error))")
                //The resource could not be loaded because the App Transport Security policy requires the use of a secure connection.
            }
        }.resume()
    }
}

struct NewsView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Star.entity(), sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)])
    var stars: FetchedResults<Star>
//添加读取CoreData的变量
    @State private var news:[News] = []
    @State var page = 1
    @State private var isLoading: Bool = false
    @State var search: String = ""
    @Binding var browsing: Bool
    @Binding var url: String
    @Binding var title: String
    @Binding var image: String
    @Binding var time: String
    @Binding var isStar: Bool
    var body: some View {
        if news.isEmpty {
            // init
            getMoreItems(page: 1)
        }
        return TabView {
            List(news) {item in
                HStack {
                    WebImageView(imageUrl: item.image)
                    VStack {
                        Text(item.title)
                        Text(item.passtime)
                    }
                }
                .onTapGesture {
                    title = item.title
                    image = item.image
                    time = item.passtime
                    url = item.path
                    isStar = false
                    browsing = true
                }
                .contextMenu{
                    Button(action: {
                        let star = Star(context: self.moc)
                        star.title = item.title
                        star.timestamp = Date.init()
                        star.image = item.image
                        star.time = item.passtime
                        star.url = item.path
                        try? self.moc.save()
                    }, label: {
                        Text("收藏")
                    })
                }
                .onAppear {
                    self.listItemAppears(item)
                }
            }
        .tabItem {
            Image(systemName: "house.fill")
            Text("阅读")
        }
            VStack{
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("搜索", text: $search)
                }
                //使用List来调取所有的Star
                List {
                ForEach(stars) { item in
                    if (search == "" || item.title!.contains(search)) {
                    HStack {
                        WebImageView(imageUrl: item.image!)
                        VStack {
                            Text(item.title!)
                            Text(item.time!)
                        }
                    }
                    .onTapGesture {
                        title = item.title!
                        image = item.image!
                        time = item.time!
                        url = item.url!
                        browsing = true
                        isStar = true
                    }
                    .contextMenu{
                        Button(action: {
                            moc.delete(item)
                            try! moc.save()
                        }, label: {
                            Text("删除")
                        })
                    }}
                }}
            }
            .tabItem {
                Image(systemName: "bookmark.fill")
                Text("\(stars.count)条收藏")
            }
        }
    }
}

extension RandomAccessCollection where Self.Element: Identifiable {
    func isThresholdItem<Item: Identifiable>(offset: Int,
                                             item: Item) -> Bool {
        guard !isEmpty else {
            return false
        }
        guard let itemIndex = firstIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
            return false
        }
        let distance = self.distance(from: itemIndex, to: endIndex)
        let offset = offset < count ? offset : count - 1
        return offset == (distance - 1)
    }
}


extension NewsView {
    private func listItemAppears<News: Identifiable>(_ item: News) {
        if news.isThresholdItem(offset: 20,item: item) && !isLoading {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.page += 1
                getMoreItems(page: self.page)
                self.isLoading = false
            }
        }
    }
    private func getMoreItems(page: Int) {
        let url = URL(string: "https://api.apiopen.top/getWangYiNews?page=\(page)&count=20")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data
                {
                    if let moreNews = try? JSONDecoder().decode(NewsResponse.self, from:data){
                        moreNews.result.forEach{self.news.append($0)}
                    }
                }
            }.resume()
    }
}


struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView(browsing: .constant(false), url: .constant(""), title: .constant(""), image: .constant(""), time: .constant(""), isStar: .constant(false)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
