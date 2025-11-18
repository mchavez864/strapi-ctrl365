import type { Schema, Struct } from '@strapi/strapi';

export interface ListNumberList extends Struct.ComponentSchema {
  collectionName: 'components_list_number_lists';
  info: {
    displayName: 'NumberList';
    icon: 'bulletList';
  };
  attributes: {
    Description: Schema.Attribute.String & Schema.Attribute.Required;
    Number: Schema.Attribute.String & Schema.Attribute.Required;
    Text: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface ListResultList extends Struct.ComponentSchema {
  collectionName: 'components_list_result_lists';
  info: {
    displayName: 'ResultList';
    icon: 'bulletList';
  };
  attributes: {
    Text: Schema.Attribute.Text;
    Title: Schema.Attribute.String;
  };
}

export interface ListTextList extends Struct.ComponentSchema {
  collectionName: 'components_list_text_lists';
  info: {
    displayName: 'TextList';
    icon: 'bulletList';
  };
  attributes: {
    Text: Schema.Attribute.Text;
  };
}

export interface SlidersCardSlider extends Struct.ComponentSchema {
  collectionName: 'components_sliders_card_sliders';
  info: {
    displayName: 'CardSlider';
    icon: 'apps';
  };
  attributes: {
    Text: Schema.Attribute.Text & Schema.Attribute.Required;
    Title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SlidersOrbSlider extends Struct.ComponentSchema {
  collectionName: 'components_sliders_orb_sliders';
  info: {
    displayName: 'OrbSlider';
    icon: 'globe';
  };
  attributes: {
    Percentage: Schema.Attribute.String;
    Symbol: Schema.Attribute.String;
    Text1: Schema.Attribute.Text;
    Text2: Schema.Attribute.String;
    Title: Schema.Attribute.String;
  };
}

export interface SlidersSlider extends Struct.ComponentSchema {
  collectionName: 'components_sliders_sliders';
  info: {
    displayName: 'Slider';
    icon: 'landscape';
  };
  attributes: {
    Image: Schema.Attribute.Media<'images'> & Schema.Attribute.Required;
    Text: Schema.Attribute.Text & Schema.Attribute.Required;
    Title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SlidersSliderList extends Struct.ComponentSchema {
  collectionName: 'components_sliders_slider_lists';
  info: {
    displayName: 'SliderList';
    icon: 'layer';
  };
  attributes: {
    TextItems: Schema.Attribute.Component<'list.result-list', true> &
      Schema.Attribute.SetMinMax<
        {
          max: 6;
        },
        number
      >;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'list.number-list': ListNumberList;
      'list.result-list': ListResultList;
      'list.text-list': ListTextList;
      'sliders.card-slider': SlidersCardSlider;
      'sliders.orb-slider': SlidersOrbSlider;
      'sliders.slider': SlidersSlider;
      'sliders.slider-list': SlidersSliderList;
    }
  }
}
