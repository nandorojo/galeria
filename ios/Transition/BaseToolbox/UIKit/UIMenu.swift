
#if canImport(UIKit)

import UIKit

@resultBuilder
public enum MenuElementsBuilder {
    public static func buildExpression(_ expression: UIMenuElement) -> [UIMenuElement] {
        [expression]
    }
    public static func buildExpression(_ expression: [UIMenuElement]) -> [UIMenuElement] {
        expression
    }
    public static func buildBlock(_ segments: [UIMenuElement]...) -> [UIMenuElement] {
        segments.flatMap { $0 }
    }
    public static func buildIf(_ segments: [UIMenuElement]?...) -> [UIMenuElement] {
        segments.flatMap { $0 ?? [] }
    }
    public static func buildEither(first: [UIMenuElement]) -> [UIMenuElement] {
        first
    }
    public static func buildEither(second: [UIMenuElement]) -> [UIMenuElement] {
        second
    }
    public static func buildArray(_ components: [[UIMenuElement]]) -> [UIMenuElement] {
        components.flatMap { $0 }
    }
    public static func buildLimitedAvailability(_ component: [UIMenuElement]) -> [UIMenuElement] {
        component
    }
}

public extension UIMenu {
    convenience init(
        title: String = "",
        image: UIImage? = nil,
        identifier: UIMenu.Identifier? = nil,
        options: UIMenu.Options = [],
        @MenuElementsBuilder builder: () -> [UIMenuElement]
    ) {
        self.init(
            title: title,
            image: image,
            identifier: identifier,
            options: options,
            children: builder()
        )
    }

    @available(iOS 15, *)
    convenience init(
        localizedTitle: String.LocalizationValue? = nil,
        localizedSubtitle: String.LocalizationValue? = nil,
        image: UIImage? = nil,
        identifier: UIMenu.Identifier? = nil,
        options: UIMenu.Options = [],
        @MenuElementsBuilder builder: () -> [UIMenuElement]
    ) {
        self.init(
            title: localizedTitle.map({ String(localized: $0) }) ?? "",
            subtitle: localizedSubtitle.map({ String(localized: $0) }),
            image: image,
            identifier: identifier,
            options: options,
            children: builder()
        )
    }

    @available(iOS 15, *)
    convenience init(
        localizedTitle: String.LocalizationValue? = nil,
        localizedSubtitle: String.LocalizationValue? = nil,
        icon: String,
        identifier: UIMenu.Identifier? = nil,
        options: UIMenu.Options = [],
        @MenuElementsBuilder builder: () -> [UIMenuElement]
    ) {
        self.init(
            title: localizedTitle.map({ String(localized: $0) }) ?? "",
            subtitle: localizedSubtitle.map({ String(localized: $0) }),
            image: UIImage(systemName: icon),
            identifier: identifier,
            options: options,
            children: builder()
        )
    }

    @available(iOS 16.0, tvOS 16.0, *)
    convenience init(
        localizedTitle: String.LocalizationValue? = nil,
        localizedSubtitle: String.LocalizationValue? = nil,
        image: UIImage? = nil,
        identifier: UIMenu.Identifier? = nil,
        options: UIMenu.Options = [],
        preferredElementSize: ElementSize,
        @MenuElementsBuilder builder: () -> [UIMenuElement]
    ) {
        self.init(
            title: localizedTitle.map({ String(localized: $0) }) ?? "",
            subtitle: localizedSubtitle.map({ String(localized: $0) }),
            image: image,
            identifier: identifier,
            options: options,
            preferredElementSize: preferredElementSize,
            children: builder()
        )
    }

    @available(iOS 16.0, tvOS 16.0, *)
    convenience init(
        localizedTitle: String.LocalizationValue? = nil,
        localizedSubtitle: String.LocalizationValue? = nil,
        icon: String,
        identifier: UIMenu.Identifier? = nil,
        options: UIMenu.Options = [],
        preferredElementSize: ElementSize,
        @MenuElementsBuilder builder: () -> [UIMenuElement]
    ) {
        self.init(
            title: localizedTitle.map({ String(localized: $0) }) ?? "",
            subtitle: localizedSubtitle.map({ String(localized: $0) }),
            image: UIImage(systemName: icon),
            identifier: identifier,
            options: options,
            preferredElementSize: preferredElementSize,
            children: builder()
        )
    }
}


public extension UIAction {
    @available(iOS 15, *)
    convenience init(
        title: String = "",
        icon systemIconName: String,
        attributes: UIMenuElement.Attributes = [],
        state: UIMenuElement.State = .off,
        handler: @escaping UIActionHandler
    )  {
        self.init(title: title,
                  image: UIImage(systemName: systemIconName),
                  attributes: attributes,
                  state: state,
                  handler: handler)
    }

    @available(iOS 15, *)
    convenience init(
        localizedTitle: String.LocalizationValue? = nil,
        image: UIImage? = nil,
        attributes: UIMenuElement.Attributes = [],
        state: UIMenuElement.State = .off,
        handler: @escaping UIActionHandler
    )  {
        self.init(title: localizedTitle.map({ String(localized: $0) }) ?? "",
                  image: image,
                  attributes: attributes,
                  state: state,
                  handler: handler)
    }

    @available(iOS 15, *)
    convenience init(
        localizedTitle: String.LocalizationValue? = nil,
        icon systemIconName: String,
        attributes: UIMenuElement.Attributes = [],
        state: UIMenuElement.State = .off,
        handler: @escaping UIActionHandler
    )  {
        self.init(title: localizedTitle.map({ String(localized: $0) }) ?? "",
                  image: UIImage(systemName: systemIconName),
                  attributes: attributes,
                  state: state,
                  handler: handler)
    }

}

@available(iOS 14.0, *)
public extension UIDeferredMenuElement {
    @available(iOS 16.0, tvOS 16.0, *)
    convenience init(
        @MenuElementsBuilder builder: @escaping () -> [UIMenuElement]
    ) {
        self.init { completion in
            completion(builder())
        }
    }
}

#endif
