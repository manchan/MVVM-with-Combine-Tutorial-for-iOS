# MVVM-with-Combine-Tutorial-for-iOS

このMVVM with Combineチュートリアルでは、CombineフレームワークとSwiftUIを使用して、MVVMパターンを使用してアプリを構築する方法を学習します。今回は良質なiOS開発のチュートリアルを数多く紹介している [raywenderlich](https://www.raywenderlich.com)の記事を翻訳、加筆修正したものになります。

今回のチュートリアルで使うファイルのダウンロードはこちらから
[資料のダウンロード](https://koenig-media.raywenderlich.com/uploads/2019/09/CombineWeatherApp.zip)

# 参照記事
[MVVM with Combine Tutorial for iOS](https://www.raywenderlich.com/4161005-mvvm-with-combine-tutorial-for-ios)

## version
**Swift 5, iOS 13, Xcode 11**

**※このチュートリアルには、Xcode 11が必要です。**


Appleの最新のフレームワークであるCombineは、SwiftUIと並んでWWDCを席巻しました。 Combineは、値を出力し、オプションで成功またはエラーで終了する論理的なデータストリームを提供するフレームワークです。これらのストリームは、近年人気が高まっているFunctional Reactive Programming（FRP）の中核にあります。 Appleは、SwiftUIとのインターフェースを作成する宣言的な方法だけでなく、Combineを使用して状態を長期にわたって管理することで前進していることが明らかになりました。このMVVM with Combineチュートリアルでは、SwiftUI、Combine、MVVMをアーキテクチャパターンとして利用する天気アプリを作成します。それが終わるまでには、次のことに満足感を得るでしょう。

- Combineを使用して状態を管理します。
- SwiftUIを使用してUIとViewModeの間にバインディングを作成します。
- これら3つの概念がすべてどのように適合するかを理解する。

このチュートリアルの終わりまでに、アプリは次のようになります。

![weather_final-1.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/8972/3eec813d-cf95-2282-8e57-6d9e72a195b7.gif)


また、この特定のアプローチの長所と短所、および問題に異なる方法で取り組む方法についても説明します。 このように、あなたの道に来るいかなる問題に対して何でもよりよく準備されています！ ：]

##初めに
このチュートリアルの上部にある[資料のダウンロード]リンクを使用して、プロジェクト資料をダウンロードすることから始めます。 CombineWeatherApp-Starterフォルダー内にあるプロジェクトを開きます。

天気情報を表示するには、[OpenWeatherMap](https://openweathermap.org/appid)に登録してAPIキーを取得する必要があります。このプロセスは数分で完了し、最後には次のような画面が表示されます。

![OpenWeatherInterface-650x294.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/8972/8f8d0dd5-22b5-6aab-2062-1667042595cb.png)


`WeatherFetcher.swift` を開きます。次に、WeatherFetcher.OpenWeatherAPIをOpenWeatherAPI構造体内のキーで更新します。

```WeatherFetcher.swift
struct OpenWeatherAPI {
  ...
  static let key = "<your key>" // Replace with your own API Key
}
```

これが完了したら、プロジェクトをビルドして実行します。メイン画面には、タップするボタンが表示されます。

![MainScreen_start-281x500.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/8972/a53b60f7-c88c-1b76-4eab-15c4efc17388.png)

「ベスト天気アプリ」をタップすると、詳細が表示されます。

![DetailScreen_finished-281x500.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/8972/fbfb7def-9ed2-79a0-b2cc-1b302956cfda.png)


現時点ではそれほど見栄えが良くありませんが、チュートリアルの終わりまでには見栄えがよくなります。 ：]

## MVVMパターンの紹介

**Model-View-ViewModel（MVVM）**パターンは、UIデザインパターンです。これは、集合的にMV*として知られるパターンのより大きなファミリーのメンバーです。これらには、[モデルビューコントローラー（MVC)](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)、[モデルビュープレゼンター（MVP）](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93presenter)などが含まれます。

これらの各パターンは、アプリの開発とテストを容易にするために、UIロジックをビジネスロジックから分離することに対処します。

パターンをよりよく理解するために、MVVMの起源を振り返るのに役立ちます。

MVCは最初のUIデザインパターンであり、その起源は1970年代の[Smalltalk言語](https://ja.wikipedia.org/wiki/Smalltalk)にまでさかのぼります。以下の画像は、MVCパターンの主要なコンポーネントを示しています。

![MVCPattern-2.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/8972/5c215c4f-6bb0-7be4-c7a3-31c6d582d4a8.png)


このパターンは、UIを、アプリケーションの状態を表すモデル、UIコントロールで構成されるビュー、およびユーザーの対話を処理し、それに応じてモデルを更新するコントローラーに分割します。

MVCパターンの1つの大きな問題は、非常に紛らわしいことです。 概念は良く見えますが、多くの場合、人々がMVCを実装するようになると、上に示した一見循環的な関係により、モデル、ビュー、コントローラーが大きくて恐ろしい混乱になります。

最近では、Martin Fowlerは、[プレゼンテーションモデル](https://martinfowler.com/eaaDev/PresentationModel.html)と呼ばれるMVCパターンのバリエーションを導入しました。これは、Microsoftによって **MVVM** という名前で採用され、普及しました。

![MVVMPattern.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/8972/c90d77a8-b1ab-03af-e0e1-ca93b78d6c59.png)


このパターンの中心となるのは、アプリのUI状態を表す特別なタイプのモデルである **ViewModel**です。 各UIコントロールの状態を詳述するプロパティが含まれています。 たとえば、テキストフィールドの現在のテキスト、または特定のボタンが有効かどうか。 また、ボタンタップやジェスチャなど、ビューが実行できるアクションも公開します。

ViewModelをビューのモデルと考えると役立ちます。

MVVMパターンの3つのコンポーネント間の関係は、MVCの同等のものよりも単純であり、以下の厳格な規則に従います。

1. ビューにはViewModelへの参照がありますが、その逆はありません。
2. ViewModelにはモデルへの参照がありますが、その逆はありません。
3. ビューにはモデルへの参照はなく、その逆もありません。

これらのルールを破ると、MVVMが間違っていることになります！

このパターンの直接的な利点は次のとおりです。

**軽量ビュー**：すべてのUIロジックはViewModel内にあるため、非常に軽量なビューになります。
**テスト**：ビューなしでアプリ全体を実行できるため、テスト性が大幅に向上します。

```
注：テストは小規模で含まれるコードチャンクとして実行されるため、ビューのテストは難しいことで有名です。　　
通常、コントローラーは、他のアプリの状態に依存するビューをシーンに追加および構成します。　　
これは、小さなテストの実行が脆弱で扱いにくい命題になる可能性があることを意味します。
```

この時点で、問題を発見した可能性があります。ビューにViewModelへの参照があり、その逆にはない場合、ViewModelはどのようにビューを更新しますか？

そう！これが、MVVMパターンの秘密の出番です。

##MVVMとデータバインディング
**データバインディング**は、ViewをViewModelに接続できるようにするものです。 今年のWWDC以前は、[RxSwift](https://github.com/ReactiveX/RxSwift)（RxCocoa経由）または[ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift)（ReactiveCocoa経由）に似たものを使用する必要がありました。 このチュートリアルでは、SwiftUIとCombineを使用してこの接続を実現する方法を探ります。

### MVVM With Combine

コンバインは実際にバインディングを行うために必要ではありませんが、その力を利用できないという意味ではありません。 SwiftUIを単独で使用してバインディングを作成できます。 ただし、Combineを使用するとより多くのパワーが得られます。 チュートリアル全体で見るように、ViewModel側にいれば、Combineを使用することが自然な選択になります。 これにより、UIで開始するチェーンをネットワークコールに至るまで明確に定義できます。 （意図した）SwiftUIとCombineを組み合わせることにより、このすべての機能を簡単に実現できます。 別の通信パターン（委任など）を使用することもできますが、そうすることで、SwiftUIによって設定された宣言型アプローチとそのバインディングを命令型と交換しています。

## アプリを構築
```
注：SwiftUIやCombineなどを初めて使用する場合、一部のスニペットに混乱する可能性があります。　　
その場合でも心配しないでください！ これは高度なトピックであり、ある程度の時間と練習が必要です。　　
理解できない場合は、アプリを実行してブレークポイントを設定し、動作を確認してください。
```

モデルレイヤーから始めて、UIに移動します。

[OpenWeatherMap](https://openweathermap.org/) APIからのJSONを扱っているため、データをデコードされたオブジェクトに変換するユーティリティメソッドが必要です。 `Parsing.swift` を開き、次を追加します。

```Parsing.swift
import Foundation
import Combine

func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, WeatherError> {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .secondsSince1970

  return Just(data)
    .decode(type: T.self, decoder: decoder)
    .mapError { error in
      .parsing(description: error.localizedDescription)
    }
    .eraseToAnyPublisher()
}

```

これは、標準の`JSONDecoder`を使用して、[OpenWeatherMap](https://openweathermap.org/) APIからJSONをデコードします。 `mapError（_ :)`および`eraseToAnyPublisher（）`の詳細については、後ほど説明します。


>注：デコードロジックは手動で記述することも、 [QuickType](https://app.quicktype.io/) などのサービスを使用することもできます。　　
>経験則として、私が所有するサービスについては、手作業で行います。 　　
>サードパーティサービスの場合、QuickTypeを使用してボイラープレートを生成します。　　
>このプロジェクトでは、 Responses.swiftにこのサービスで生成されたエンティティがあります。


次に、`WeatherFetcher.swift`を開きます。このエンティティは、OpenWeatherMap APIから情報を取得し、データを解析してそのコンシューマーに提供します。

優れたSwift市民のように、プロトコルから始めます。インポートの下に次を追加します。

```WeatherFetcher.swift
protocol WeatherFetchable {
  func weeklyWeatherForecast(
    forCity city: String
  ) -> AnyPublisher<WeeklyForecastResponse, WeatherError>

  func currentWeatherForecast(
    forCity city: String
  ) -> AnyPublisher<CurrentWeatherForecastResponse, WeatherError>
}
```

最初の画面で最初の方法を使用して、今後5日間の天気予報を表示します。 2番目を使用して、より詳細な天気情報を表示します。

`AnyPublisher`とは何か、なぜAnyPublisherに2つの型パラメーターがあるのか疑問に思われるかもしれません。 これは、今後の計算、または購読すると実行される何かと考えることができます。 最初のパラメーター（`WeeklyForecastResponse`）は、計算が成功した場合に返す型を参照し、ご想像のとおり、2番目は失敗した場合の型（`WeatherError`）を参照します。

クラス宣言の下に次のコードを追加して、これらの2つのメソッドを実装します。

```WeatherFetcher.swift
// MARK: - WeatherFetchable
extension WeatherFetcher: WeatherFetchable {
  func weeklyWeatherForecast(
    forCity city: String
  ) -> AnyPublisher<WeeklyForecastResponse, WeatherError> {
    return forecast(with: makeWeeklyForecastComponents(withCity: city))
  }

  func currentWeatherForecast(
    forCity city: String
  ) -> AnyPublisher<CurrentWeatherForecastResponse, WeatherError> {
    return forecast(with: makeCurrentDayForecastComponents(withCity: city))
  }

  private func forecast<T>(
    with components: URLComponents
  ) -> AnyPublisher<T, WeatherError> where T: Decodable {
    // 1
    guard let url = components.url else {
      let error = WeatherError.network(description: "Couldn't create URL")
      return Fail(error: error).eraseToAnyPublisher()
    }

    // 2
    return session.dataTaskPublisher(for: URLRequest(url: url))
      // 3
      .mapError { error in
        .network(description: error.localizedDescription)
      }
      // 4
      .flatMap(maxPublishers: .max(1)) { pair in
        decode(pair.data)
      }
      // 5
      .eraseToAnyPublisher()
  }
}
```

これが何をするかです：

1. `URLComponents`から`URL`のインスタンスを作成してみてください。 これが失敗した場合、`Fail`値にラップされたエラーを返します。 次に、その型を`AnyPublisher`に消去します。これがメソッドの戻り値型であるためです。

2. 新しい`URLSession`メソッド`dataTaskPublisher(for :)`を使用してデータを取得します。 このメソッドは`URLRequest`のインスタンスを受け取り、タプル`（Data、URLResponse）`または`URLError`を返します。

3. メソッドは`AnyPublisher <T、WeatherError>`を返すため、エラーを`URLError`から`WeatherError`にマッピングします。

4. `flatMap`の使用は、独自の投稿に値します。 ここでは、JSONとしてサーバーから送信されるデータを完全なオブジェクトに変換するために使用します。 これを実現するには、`decode(_ :)`を補助関数として使用します。 ネットワークリクエストによって出力される最初の値のみに関心があるため、`.max（1）`を設定します。

5. `eraseToAnyPublisher()`を使用しない場合、`flatMap`によって返される完全なタイプを引き継ぐ必要があります：`Publishers.FlatMap <AnyPublisher <_、WeatherError>,Publishers.MapError <URLSession.DataTaskPublisher、WeatherError >>`。 APIのコンシューマーとして、これらの詳細に悩まされることは望ましくありません。 したがって、APIの人間工学を改善するには、`AnyPublisher`のタイプを消去します。 新しい変換（`filter`など）を追加すると、返される型が変更されるため、実装の詳細が明らかとなるため、これも便利です。

モデルレベルでは、必要なものがすべて揃っているはずです。アプリをビルドして、すべてが機能することを確認します。

## ViewModelsに飛び込む
次に、週次予測画面を駆動するViewModelを作ります。

![weekly_forecast.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/8972/c84608f2-268c-6694-17f8-fd160a67e071.gif)


**WeeklyWeatherViewModel.swift**を開き、以下を追加します。

```WeeklyWeatherViewModel.swift
import SwiftUI
import Combine

// 1
class WeeklyWeatherViewModel: ObservableObject, Identifiable {
  // 2
  @Published var city: String = ""

  // 3
  @Published var dataSource: [DailyWeatherRowViewModel] = []

  private let weatherFetcher: WeatherFetchable

  // 4
  private var disposables = Set<AnyCancellable>()

  init(weatherFetcher: WeatherFetchable) {
    self.weatherFetcher = weatherFetcher
  }
}
```

そのコードの機能は次のとおりです。

1. `WeeklyWeatherViewModel`を`ObservableObject`および`Identifiable`に準拠させます。 これらに準拠するということは、`WeeklyWeatherViewModel`のプロパティをバインディングとして使用できることを意味します。 ビューレイヤーに到達すると、作成方法が表示されます。

2. 適切にデリゲートされた`@Published`修飾子により、`city`プロパティを監視することができます。 これを活用する方法がすぐにわかります。

3. ビューのデータソースをViewModelに保持します。 これは、MVCで行うことに慣れている場合とは対照的です。 プロパティには`@Published`のマークが付けられているため、コンパイラーは自動的にパブリッシャーを合成します。 SwiftUIはそのパブリッシャーをサブスクライブし、プロパティを変更すると画面を再描画します。

4. `disposables`は、リクエストへの参照のコレクションと考えてください。 これらの参照を保持しないと、送信するネットワークリクエストは保持されず、サーバーからの応答を取得できなくなります。

次に、イニシャライザの下に以下を追加して`WeatherFetcher`を使用します。

```WeeklyWeatherViewModel.swift
func fetchWeather(forCity city: String) {
  // 1
  weatherFetcher.weeklyWeatherForecast(forCity: city)
    .map { response in
      // 2
      response.list.map(DailyWeatherRowViewModel.init)
    }

    // 3
    .map(Array.removeDuplicates)

    // 4
    .receive(on: DispatchQueue.main)

    // 5
    .sink(
      receiveCompletion: { [weak self] value in
        guard let self = self else { return }
        switch value {
        case .failure:
          // 6
          self.dataSource = []
        case .finished:
          break
        }
      },
      receiveValue: { [weak self] forecast in
        guard let self = self else { return }

        // 7
        self.dataSource = forecast
    })

    // 8
    .store(in: &disposables)
}
```

ここでは非常に多くのことが行われていますが、この後はすべてが簡単になると約束しています。

1. [OpenWeatherMap](https://openweathermap.org/) APIから情報を取得する新しいリクエストを作成することから始めます。引数として都市名を渡します。

2. レスポンス（`WeeklyForecastResponse`オブジェクト）を`DailyWeatherRowViewModel`オブジェクトの配列にマップします。 このエンティティは、リスト内の単一の行を表します。 `DailyWeatherRowViewModel.swift`にある実装を確認できます。 MVVMでは、ViewModelレイヤーが必要なデータをViewに正確に公開することが最重要です。 View a `WeeklyForecastResponse`に直接公開することは意味がありません。これにより、Viewレイヤーがモデルを消費するためにフォーマットするように強制されます。 ビューをできるだけダムにし、レンダリングのみに関係するようにすることをお勧めします。

3. [OpenWeatherMap](https://openweathermap.org/) APIは、時刻に応じて同じ日の複数の温度を返すため、重複を削除します。 `Array + Filtering.swift`をチェックして、その方法を確認できます。

4. サーバーからのデータの取得、またはJSONのblobの解析はバックグラウンドキューで行われますが、UIの更新はメインキューで行われる必要があります。 `receive(on:)`を使用すると、ステップ5、6、および7で行う更新が適切な場所で行われるようになります。

5. `sink(receiveCompletion:receiveValue:)`を介してパブリッシャーを開始します。これは、それに応じてdataSourceを更新する場所です。成功または失敗した完了の処理は、値の処理とは別に発生することに注意することが重要です。

6. 障害が発生した場合、`dataSource`を空の配列として設定します。

7. 新しい予報が到着したときに`dataSource`を更新します。

8. 最後に、キャンセル可能な参照を `disposables`セットに追加します。前述のように、この参照を有効にしないと、ネットワークパブリッシャーはすぐに終了します。

# 週間天気図
**WeeklyWeatherView.swift**を開いて開始します。次に、viewModelプロパティと初期化子を構造体内に追加します。

```WeeklyWeatherView.swift
@ObservedObject var viewModel: WeeklyWeatherViewModel

init(viewModel: WeeklyWeatherViewModel) {
  self.viewModel = viewModel
}

```

`@ObservedObject`プロパティデリゲートは、`WeeklyWeatherView`と`WeeklyWeatherViewModel`間の接続を確立します。 つまり、`WeeklyWeatherView`のプロパティ`objectWillChange`が値を送信すると、データソースが変更されようとしていることがビューに通知され、結果としてビューが再レンダリングされます。

次に、**SceneDelegate.swift**を開き、古い`weeklyView`プロパティを次のものに置き換えます。

```SceneDelegate.swift
let fetcher = WeatherFetcher()
let viewModel = WeeklyWeatherViewModel(weatherFetcher: fetcher)
let weeklyView = WeeklyWeatherView(viewModel: viewModel)
```

プロジェクトを再度ビルドして、すべてがコンパイルされることを確認します。

**WeeklyWeatherView.swift**に戻り、`body`をアプリの実際の実装に置き換えます。

```WeeklyWeatherView.swift
var body: some View {
  NavigationView {
    List {
      searchField

      if viewModel.dataSource.isEmpty {
        emptySection
      } else {
        cityHourlyWeatherSection
        forecastSection
      }
    }
    .listStyle(GroupedListStyle())
    .navigationBarTitle("Weather ⛅️")
  }
}

```

`dataSource`が空の場合、空のセクションが表示されます。それ以外の場合は、予測セクションと、検索した特定の都市の詳細を表示する機能が表示されます。ファイルの下部に次を追加します。

```WeeklyWeatherView.swift
private extension WeeklyWeatherView {
  var searchField: some View {
    HStack(alignment: .center) {
      // 1
      TextField("e.g. Cupertino", text: $viewModel.city)
    }
  }

  var forecastSection: some View {
    Section {
      // 2
      ForEach(viewModel.dataSource, content: DailyWeatherRow.init(viewModel:))
    }
  }

  var cityHourlyWeatherSection: some View {
    Section {
      NavigationLink(destination: CurrentWeatherView()) {
        VStack(alignment: .leading) {
          // 3
          Text(viewModel.city)
          Text("Weather today")
            .font(.caption)
            .foregroundColor(.gray)
        }
      }
    }
  }

  var emptySection: some View {
    Section {
      Text("No results")
        .foregroundColor(.gray)
    }
  }
}
```

ここにはかなりのコードがありますが、主な部分は3つだけです。

1. 最初のバインド! `$viewModel.city`は、`TextField`に入力する値と`WeeklyWeatherViewModel` の `city` プロパティの間の接続を確立します。 `$` を使用すると、`city` プロパティを `Binding<String>` に変換できます。 これは、`WeeklyWeatherViewModel` が `ObservableObject` に準拠し、`@ObservedObject`プロパティラッパーで宣言されているためにのみ可能です。

2. 独自のViewModelを使用して、毎日の天気予報の行を初期化します。 **DailyWeatherRow.swift**を開いて、動作を確認します。

3. 派手なバインドなしで、引き続き`WeeklyWeatherViewModel`プロパティを使用してアクセスできます。これは、都市名を`Text`で表示するだけです。

アプリをビルドして実行すると、次のように表示されます。


<img width="375" alt="Simulator-Screen-Shot-iPhone-8-2019-07-06-at-17.36.58.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/8972/a2bfeaea-f186-6a04-b1be-9fad538a7756.png">


驚いたことに、またはそうではなく、何も起こりません。 これは、実際のHTTPリクエストに`city`バインドをまだ接続していないためです。 それを修正しましょう。

**WeeklyWeatherViewModel.swift**を開き、現在の初期化子を次のものに置き換えます。

```WeeklyWeatherViewModel.swift
// 1
init(
  weatherFetcher: WeatherFetchable,
  scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")
) {
  self.weatherFetcher = weatherFetcher
 
  // 2
  _ = $city
    // 3
    .dropFirst(1)
    // 4
    .debounce(for: .seconds(0.5), scheduler: scheduler)
    // 5
    .sink(receiveValue: fetchWeather(forCity:))
}

```

このコードは、SwiftUIとCombineの両方の世界をつなぐため、非常に重要です。

1. `scheduler`パラメータを追加して、HTTPリクエストが使用するキューを指定できるようにします。

2. `city`プロパティは`@Published`プロパティデリゲートを使用するため、他の`Publisher`と同様に機能します。 これは、それが観察可能であり、`Publisher`で利用可能な他の方法も利用できることを意味します。

3. 観測値を作成するとすぐに、`$city`は最初の値を出力します。 最初の値は空の文字列であるため、意図しないネットワーク呼び出しを避けるためにそれをスキップする必要があります。

4. `debounce(for:scheduler:)`を使用して、ユーザー体験を向上させます。 これがないと、`fetchWeather`は入力されたすべての文字に対して新しいHTTP要求を作成します。 デバウンスは、ユーザーが入力を停止して最終的に値を送信するまで0.5秒待機することで機能します。 [RxMarbles](https://rxmarbles.com/#debounce)でこの動作の優れた視覚化を見つけることができます。 また、`scheduler`を引数として渡します。つまり、発行される値はその特定のキューに置かれます。 経験則：バックグラウンドキューで値を処理し、メインキューで配信する必要があります。

5. 最後に、`sink(receiveValue:)`を介してこれらのイベントを観察し、以前に実装した`fetchWeather(forCity:)`でそれらを処理します。

プロジェクトをビルドして実行します。最終的にメイン画面が動作しているのが見えるはずです。

![weekly_forecast (1).gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/8972/9d07f5ba-46c1-5ca4-efd1-512e95608c12.gif)

## ナビゲーションと現在の天気画面
アーキテクチャパターンとしてのMVVMは、細かい点には触れません。 一部の決定は、開発者の裁量に任されています。 それらの1つは、ある画面から別の画面にナビゲートする方法、およびその責任を所
有するエンティティです。 SwiftUIは、`NavigationLink`の使用に関するヒントを提供するため、このチュートリアルではこれを使用します。

`NavigationLink`の最も基本的なイニシャライザーである`public init<V>(destination:V、label: () -> Label）where V：View`を見ると、引数として`View`を期待していることがわかります。 これは、本質的に、現在のビュー（起点）を別のビュー（終点）に結び付けます。 この関係は、よりシンプルなアプリでは問題ないかもしれませんが、外部ロジック（サーバー応答など）に基づいて異なる宛先を必要とする複雑なフローがある場合、問題が発生する可能性があります。

MVVMレシピに従って、ViewはViewModelに次に何をするかを尋ねる必要がありますが、予想されるパラメーターはViewであり、ViewModelはこれらの懸念を認識しないため、これは注意が必要です。 この問題は、アプリケーション全体のルーティングを管理するためにViewModelと共に動作する,さらに別のエンティティによって表されるFlowControllersまたはCoordinatorsを介して解決されます。 このアプローチはうまく拡張できますが、`NavigationLink`のようなものを使用するのを妨げるでしょう。

これらはすべてこのチュートリアルの範囲外であるため、ここでは実用的であり、ハイブリッドアプローチを使用します。

ナビゲーションに進む前に、まず`CurrentWeatherView`と`CurrentWeatherViewModel`を更新します。 **CurrentWeatherViewModel.swift**を開き、次を追加します。

```CurrentWeatherViewModel.swift
import SwiftUI
import Combine

// 1
class CurrentWeatherViewModel: ObservableObject, Identifiable {
  // 2
  @Published var dataSource: CurrentWeatherRowViewModel?

  let city: String
  private let weatherFetcher: WeatherFetchable
  private var disposables = Set<AnyCancellable>()

  init(city: String, weatherFetcher: WeatherFetchable) {
    self.weatherFetcher = weatherFetcher
    self.city = city
  }

  func refresh() {
    weatherFetcher
      .currentWeatherForecast(forCity: city)
      // 3
      .map(CurrentWeatherRowViewModel.init)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] value in
        guard let self = self else { return }
        switch value {
        case .failure:
          self.dataSource = nil
        case .finished:
          break
        }
        }, receiveValue: { [weak self] weather in
          guard let self = self else { return }
          self.dataSource = weather
      })
      .store(in: &disposables)
  }
}
```

`CurrentWeatherViewModel`は、`WeeklyWeatherViewModel`で以前に行ったことを模倣します。

1. `CurrentWeatherViewModel`を`ObservableObject`および`Identifiable`に準拠させます。
2. オプションの`CurrentWeatherRowViewModel`をデータソースとして公開します。

3. `CurrentWeatherForecastResponse`の形式で新しい値を`CurrentWeatherRowViewModel`に変換します。

次に、UIです。 `CurrentWeatherView.swift`を開き、`struct`の上部に初期化子を追加します。

```CurrentWeatherView.swift
@ObservedObject var viewModel: CurrentWeatherViewModel

init(viewModel: CurrentWeatherViewModel) {
  self.viewModel = viewModel
}

```

これは、`WeeklyWeatherView`で適用したのと同じパターンに従います。おそらく、独自のプロジェクトでSwiftUIを使用するときに実行することです。ViewにViewModelを挿入し、そのパブリックAPIにアクセスします。

ここで、`body` のcomputed propertyを更新します。

```CurrentWeatherView.swift
var body: some View {
  List(content: content)
    .onAppear(perform: viewModel.refresh)
    .navigationBarTitle(viewModel.city)
    .listStyle(GroupedListStyle())
}
```

`onAppear(perform:)`メソッドの使用に気付くでしょう。 これは、type `() -> Void`の関数を取り、ビューが表示されたときに実行します。 この場合、`dataSource`を更新できるように、ViewModelで`refresh()`を呼び出します。

最後に、ファイルの最後に次を追加します。

```CurrentWeatherView.swift
private extension CurrentWeatherView {
  func content() -> some View {
    if let viewModel = viewModel.dataSource {
      return AnyView(details(for: viewModel))
    } else {
      return AnyView(loading)
    }
  }

  func details(for viewModel: CurrentWeatherRowViewModel) -> some View {
    CurrentWeatherRow(viewModel: viewModel)
  }

  var loading: some View {
    Text("Loading \(viewModel.city)'s weather...")
      .foregroundColor(.gray)
  }
}
```

これにより、残りのUIが少し追加されます。

`CurrentWeatherView`イニシャライザを変更したため、プロジェクトはまだコンパイルされていません。

ほとんどの部分が揃ったので、次はナビゲーションをまとめましょう。 **WeeklyWeatherBuilder.swift**を開き、次を追加します。

```WeeklyWeatherBuilder.swift
import SwiftUI

enum WeeklyWeatherBuilder {
  static func makeCurrentWeatherView(
    withCity city: String,
    weatherFetcher: WeatherFetchable
  ) -> some View {
    let viewModel = CurrentWeatherViewModel(
      city: city,
      weatherFetcher: weatherFetcher)
    return CurrentWeatherView(viewModel: viewModel)
  }
}
```


このエンティティは、`WeeklyWeatherView`からナビゲートするときに必要な画面を作成するファクトリーとして機能します。

**WeeklyWeatherViewModel.swift**を開き、ファイルの下部に以下を追加してビルダーの使用を開始します。

```WeeklyWeatherViewModel.swift
extension WeeklyWeatherViewModel {
  var currentWeatherView: some View {
    return WeeklyWeatherBuilder.makeCurrentWeatherView(
      withCity: city,
      weatherFetcher: weatherFetcher
    )
  }
}

```

最後に、**WeeklyWeatherView.swift**を開き、`cityHourlyWeatherSection`プロパティの実装を次のように変更します。


ここで重要なのは、`viewModel.currentWeatherView`です。 `WeeklyWeatherView`は、次に表示するビューを`WeeklyWeatherViewModel`に尋ねます。 `WeeklyWeatherViewModel`は、`WeeklyWeatherBuilder`を使用して必要なビューを提供します。 責任の間に良い分離があり、同時にそれらの間の全体的な関係を容易に追跡できます。

ナビゲーションの問題を解決する方法は他にもたくさんあります。 一部の開発者は、Viewレイヤーがナビゲートする場所や、ナビゲーションがどのように発生するか（モーダルまたはプッシュ）を認識すべきではないと主張します。 それが議論である場合、Appleが`NavigationLink`で提供しているものを使用することはもはや意味がありません。 プラグマティズムとスケーラビリティのバランスをとることが重要です。 このチュートリアルは前者に傾いています。

プロジェクトをビルドして実行します。 すべてが期待どおりに動作するはずです！ 天気アプリの作成おめでとうございます！ ：]

![weather_final-1 (1).gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/8972/212a48c2-8d3d-46e2-2c4e-2d0c1501fb67.gif)

## 追加でナビゲーションタイトルを更新してみる
ここまでがチュートリアルの内容でしたが、簡単な機能を追加してみることにします。

- 入力した `city` の今日の天気に応じて絵文字 雨☔, 曇り🌥, 晴れ☀️を表示
- 週間天気にも絵文字を表示し視覚的にわかりやすく

やはりViewModelからいきます。
**DailyWeatherRowViewModel.swift** に以下のプロパティを追加

```DailyWeatherRowViewModel.swift

  var emoji: String {
    switch item.weather[0].main {
    case .clear:
      return "☀️"
    case .clouds:
      return "🌥"
    case .rain:
      return "☔️"
    }
  }
```

週間天気の一行目の天気の列挙体に合わせて、絵文字をマッピングします。
タイムゾーンなどは考慮していません。

次に**WeeklyWeatherViewModel.swift**を編集します。

```WeeklyWeatherViewModel.swift
@Published var todaysWeatherEmoji: String = ""
```
`Published`修飾子の`todaysWeatherEmoji`を絵文字表示用に定義し、
値の変更を監視します。


```WeeklyWeatherViewModel.swift
  func fetchWeather(forCity city: String) {

    weatherFetcher.weeklyWeatherForecast(forCity: city)
      .map { response in
        response.list.map(DailyWeatherRowViewModel.init)
      }
      .map(Array.removeDuplicates)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] value in
          guard let self = self else { return }
          switch value {
          case .failure:
            self.dataSource = []
            // 1
            self.todaysWeatherEmoji = ""
          case .finished:
            break
          }
        },
        receiveValue: { [weak self] forecast in
          guard let self = self else { return }
          // 2
          self.todaysWeatherEmoji = forecast.first?.emoji ?? ""          
          self.dataSource = forecast
      })
      .store(in: &disposables)
  }
```

1. エラー発生時は空を代入します。
2. 流れてきた週間天気表示用の配列から `forecast.first?.emoji` を代入します。

最後に２点変更して終了です。
**WeeklyWeatherView.swift**を編集

```WeeklyWeatherView.swift
.navigationBarTitle("Weather \(self.viewModel.todaysWeatherEmoji)")
```
`city`の変更に応じて、`WeeklyWeatherViewModel`の`todaysWeatherEmoji`の更新がかかり、ナビゲーションバーのタイトルが更新されます。

以下、**DailyWeatherRow.swift** にてタイトルに絵文字を連結させます。

```DailyWeatherRow.swift
VStack(alignment: .leading) {
  Text("\(viewModel.title) \(viewModel.emoji)")
    .font(.body)
  Text("\(viewModel.fullDescription)")
    .font(.footnote)
  }
   .padding(.leading, 8)
```

Finish!
![画面収録 2019-09-23 午前10.17.56.2019-09-23 10_23_19 AM.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/8972/dddbd8df-cf82-dff5-1a01-3b9c8f36abc9.gif)


## ここからどこへ行きますか？

このチュートリアルでは、MVVM、Combine、およびSwiftを使用して多くのことを説明しました。 これらのトピックはそれぞれチュートリアルであり、今日のゴールは、あなたが新しいことをはじめ、iOS開発の未来を垣間見ることでした。個人的な見解としては,AppleがFRPを正式にサポートした以上、新規のiOSアプリで中規模以上のものに関してはSwiftUI×Combineを使うことを強くおすすめします。

[Advanced iOS App Architecture](https://store.raywenderlich.com/products/advanced-ios-app-architecture)の今後の更新では、本日取り上げたトピックの詳細を説明します。 アップデートに注目してください！

また、Combineの使用についてさらに学習するには、新しい本[「Combine：Asynchronous Programming with Swift！」](https://store.raywenderlich.com/products/combine-asynchronous-programming-with-swift)をご覧ください。

ぜひ、このMVVMとCombineチュートリアルをお楽しみください。 ご質問やご意見がありましたら、以下コメント欄に投稿してください。
